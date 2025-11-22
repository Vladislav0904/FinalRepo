import UIKit

final class MatchDetailsCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let repository: TennisRepositoryProtocol
    private let favoritesService: FavoritesServiceProtocol?
    private let matchKey: String

    init(
        navigationController: UINavigationController,
        repository: TennisRepositoryProtocol,
        matchKey: String,
        favoritesService: FavoritesServiceProtocol? = nil
    ) {
        self.navigationController = navigationController
        self.repository = repository
        self.matchKey = matchKey
        self.favoritesService = favoritesService
    }

    @Injected private var imageCache: ImageCacheServiceProtocol

    func start() {
        let viewModel = MatchDetailsViewModel(
            repository: repository,
            matchKey: matchKey,
            imageCache: imageCache
        )
        viewModel.onNavigation = { [weak self] action in
            switch action {
            case .showPlayerDetails(let player):
                self?.showPlayerDetails(player: player)
            case .showMatchDetails:
                break
            }
        }
        let viewController = MatchDetailsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    @Injected private var injectedFavoritesService: FavoritesServiceProtocol

    func showPlayerDetails(player: Player) {
        let service = favoritesService ?? injectedFavoritesService
        let playerDetailsCoordinator = PlayerDetailsCoordinator(
            navigationController: navigationController,
            repository: repository,
            favoritesService: service,
            player: player
        )
        addChildCoordinator(playerDetailsCoordinator)
        playerDetailsCoordinator.start()
    }
}
