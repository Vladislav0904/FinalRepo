import UIKit

final class PlayerDetailsCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let repository: TennisRepositoryProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let player: Player

    init(
        navigationController: UINavigationController,
        repository: TennisRepositoryProtocol,
        favoritesService: FavoritesServiceProtocol,
        player: Player
    ) {
        self.navigationController = navigationController
        self.repository = repository
        self.favoritesService = favoritesService
        self.player = player
    }

    @Injected private var imageCache: ImageCacheServiceProtocol

    func start() {
        let viewModel = PlayerDetailsViewModel(
            repository: repository,
            favoritesService: favoritesService,
            player: player,
            imageCache: imageCache
        )
        viewModel.onNavigation = { [weak self] action in
            switch action {
            case .showPlayerDetails(let player):
                self?.showPlayerDetails(player: player)
            case .showMatchDetails(let matchKey):
                self?.showMatchDetails(matchKey: matchKey)
            }
        }
        let viewController = PlayerDetailsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
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

    func showMatchDetails(matchKey: String) {
        let coordinator = MatchDetailsCoordinator(
            navigationController: navigationController,
            repository: repository,
            matchKey: matchKey,
            favoritesService: favoritesService
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
}
