import Foundation
import Combine

@MainActor
class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    private(set) var cancellables = Set<AnyCancellable>()
    var onNavigation: ((NavigationAction) -> Void)?
    let imageCache: ImageCacheServiceProtocol

    init(imageCache: ImageCacheServiceProtocol) {
        self.imageCache = imageCache
    }

    func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }

    deinit {
        cancellables.removeAll()
    }
}
