import Foundation

protocol NetworkServiceProtocol {
    nonisolated func request<T: Decodable>(
        endpoint: String,
        parameters: [String: Any]?,
        responseType: T.Type
    ) async throws -> T
}
