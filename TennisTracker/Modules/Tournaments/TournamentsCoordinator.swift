import UIKit

final class TournamentsCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let repository: TennisRepositoryProtocol
    private let favoritesService: FavoritesServiceProtocol?

    init(
        navigationController: UINavigationController,
        repository: TennisRepositoryProtocol,
        favoritesService: FavoritesServiceProtocol? = nil
    ) {
        self.navigationController = navigationController
        self.repository = repository
        self.favoritesService = favoritesService
    }

    @Injected private var imageCache: ImageCacheServiceProtocol

    func start() {
        let viewModel = TournamentsViewModel(
            repository: repository,
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
        let viewController = TournamentsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }

    func showPlayerDetails(player: Player) {
        guard let favoritesService = favoritesService else { return }

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
