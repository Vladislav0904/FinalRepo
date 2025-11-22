import UIKit

final class MainCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let tabBarController: UITabBarController
    private let window: UIWindow

    @Injected private var repository: TennisRepositoryProtocol
    @Injected private var favoritesService: FavoritesServiceProtocol

    init(navigationController: UINavigationController, window: UIWindow) {
        self.navigationController = navigationController
        self.window = window
        self.tabBarController = UITabBarController()
    }

    func start() {
        let liveMatchesNav = UINavigationController()
        let tournamentsNav = UINavigationController()
        let rankingsNav = UINavigationController()
        let favouritesNav = UINavigationController()

        let liveMatchesCoordinator = LiveMatchesCoordinator(
            navigationController: liveMatchesNav,
            repository: repository,
            favoritesService: favoritesService
        )

        let tournamentsCoordinator = TournamentsCoordinator(
            navigationController: tournamentsNav,
            repository: repository,
            favoritesService: favoritesService
        )

        let rankingsCoordinator = RankingsCoordinator(
            navigationController: rankingsNav,
            repository: repository,
            favoritesService: favoritesService
        )

        let favouritesCoordinator = FavouritesCoordinator(
            navigationController: favouritesNav,
            repository: repository,
            favoritesService: favoritesService
        )

        liveMatchesCoordinator.start()
        tournamentsCoordinator.start()
        rankingsCoordinator.start()
        favouritesCoordinator.start()

        liveMatchesNav.tabBarItem = UITabBarItem(
            title: StringConstants.TabBar.live,
            image: UIImage(systemName: ImageConstants.SystemIcons.livePhoto),
            selectedImage: UIImage(systemName: ImageConstants.SystemIcons.livePhotoFill)
        )

        tournamentsNav.tabBarItem = UITabBarItem(
            title: StringConstants.TabBar.tournaments,
            image: UIImage(systemName: ImageConstants.SystemIcons.calendar),
            selectedImage: UIImage(systemName: ImageConstants.SystemIcons.calendarFill)
        )

        rankingsNav.tabBarItem = UITabBarItem(
            title: StringConstants.TabBar.rankings,
            image: UIImage(systemName: ImageConstants.SystemIcons.trophy),
            selectedImage: UIImage(systemName: ImageConstants.SystemIcons.trophyFill)
        )

        favouritesNav.tabBarItem = UITabBarItem(
            title: StringConstants.TabBar.favorites,
            image: UIImage(systemName: ImageConstants.SystemIcons.star),
            selectedImage: UIImage(systemName: ImageConstants.SystemIcons.starFill)
        )

        tabBarController.viewControllers = [liveMatchesNav, tournamentsNav, rankingsNav, favouritesNav]
        tabBarController.tabBar.tintColor = ColorConstants.tabBarTint
        tabBarController.tabBar.backgroundColor = .systemBackground

        liveMatchesNav.isNavigationBarHidden = false
        tournamentsNav.isNavigationBarHidden = false
        rankingsNav.isNavigationBarHidden = false
        favouritesNav.isNavigationBarHidden = false

        addChildCoordinator(liveMatchesCoordinator)
        addChildCoordinator(tournamentsCoordinator)
        addChildCoordinator(rankingsCoordinator)
        addChildCoordinator(favouritesCoordinator)

        window.rootViewController = tabBarController
        window.backgroundColor = .systemBackground
    }
}
