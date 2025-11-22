import UIKit

final class RankingsCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let repository: TennisRepositoryProtocol
    private let favoritesService: FavoritesServiceProtocol

    init(
        navigationController: UINavigationController,
        repository: TennisRepositoryProtocol,
        favoritesService: FavoritesServiceProtocol
    ) {
        self.navigationController = navigationController
        self.repository = repository
        self.favoritesService = favoritesService
    }

    @Injected private var imageCache: ImageCacheServiceProtocol

    func start() {
        let viewModel = RankingsViewModel(
            repository: repository,
            imageCache: imageCache
        )
        viewModel.onNavigation = { [weak self] action in
            switch action {
            case .showPlayerDetails(let player):
                self?.showPlayerDetails(player: player)
            case .showMatchDetails:
                break // Rankings doesn't navigate to matches
            }
        }
        let viewController = RankingsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }

    func showPlayerDetails(player: Player) {
        let playerDetailsCoordinator = PlayerDetailsCoordinator(
            navigationController: navigationController,
            repository: repository,
            favoritesService: favoritesService,
            player: player
        )
        addChildCoordinator(playerDetailsCoordinator)
        playerDetailsCoordinator.start()
    }
}
