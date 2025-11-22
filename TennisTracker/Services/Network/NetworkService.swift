import Foundation

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let apiKey: String

    init(session: URLSession = .shared, apiKey: String) {
        self.session = session
        self.apiKey = apiKey
    }

    func decodeErrorResponse(from data: Data) -> APIErrorResponse? {
        let tempDecoder = JSONDecoder()
        tempDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? tempDecoder.decode(APIErrorResponse.self, from: data)
    }

    nonisolated func request<T: Decodable>(
        endpoint: String,
        parameters: [String: Any]?,
        responseType: T.Type
    ) async throws -> T {
        guard var urlComponents = URLComponents(string: APIConstants.baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var queryItems: [URLQueryItem] = []

        if let parameters = parameters {
            for (key, value) in parameters {
                let stringValue = "\(value)"
                queryItems.append(URLQueryItem(name: key, value: stringValue))
            }
        }

        queryItems.append(URLQueryItem(name: APIConstants.Parameters.apiKey, value: apiKey))
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = APIConstants.defaultTimeout

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }

            // Check for API errors using nonisolated function
            let errorResponse = await decodeErrorResponse(from: data)

            if let errorResponse = errorResponse,
               let error = errorResponse.error, error == "1",
               let errors = errorResponse.result, !errors.isEmpty {
                let errorMessages = errors.compactMap { $0.msg }.joined(separator: ", ")
                throw NetworkError.networkError(
                    NSError(
                        domain: "APIError",
                        code: errors.first?.cod ?? 0,
                        userInfo: [NSLocalizedDescriptionKey: errorMessages]
                    )
                )
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch let decodingError as DecodingError {
                throw NetworkError.decodingError(decodingError)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}
