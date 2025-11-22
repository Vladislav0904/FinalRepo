import UIKit

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        window.backgroundColor = .systemBackground

        let mainCoordinator = MainCoordinator(
            navigationController: navigationController,
            window: window
        )
        addChildCoordinator(mainCoordinator)
        mainCoordinator.start()
    }
}
