import UIKit

protocol CoordinatorProtocol {
    
    func start ()
}

final class MainCoordinator: CoordinatorProtocol {
    
    // MARK: - Properties
    private let window: UIWindow
    private lazy var tabBarController = UITabBarController()
    private lazy var navigationControllers = MainCoordinator.makeNavigationControllers()

    // init
    init(window: UIWindow) {
        self.window = window
    }
    
    // MARK: - func
    func start() {
        
        setupPhotoVC()
        setupFavoritesVC()
        
        let navigationControllers = NavControllerSettings.allCases.compactMap {
            self.navigationControllers[$0]
        }
        tabBarController.setViewControllers(navigationControllers, animated: true)
        tabBarController.tabBar.tintColor = .black
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
    }
    
    private func setupPhotoVC() {
        guard let navigationController = navigationControllers[.photos] else { return }
        let mainVC = MainViewController()
        mainVC.delegate = self
        navigationController.setViewControllers([mainVC], animated: true)
    }
    
    private func setupFavoritesVC() {
        guard let navigationController = navigationControllers[.favorites] else { return }
        let favoritesVC = FavoritesViewController()
        favoritesVC.delegate = self
        navigationController.setViewControllers([favoritesVC], animated: true)
    }
    
    fileprivate static func makeNavigationControllers() -> [NavControllerSettings: UINavigationController] {
        var result: [NavControllerSettings: UINavigationController] = [:]
        NavControllerSettings.allCases.forEach { navControllerKey in
            let navigationController = UINavigationController()
            let tabBarItem = UITabBarItem(title: navControllerKey.title,
                                          image: navControllerKey.image,
                                          tag: navControllerKey.rawValue)
            navigationController.tabBarItem = tabBarItem
            result[navControllerKey] = navigationController
        }
        return result
    }
}

// MARK: - MainViewControllerDelegate
extension MainCoordinator: MainViewControllerDelegate {
    
    func mainViewControllerDidSelectPhoto(_ selectedPhoto: ResultData) {
        
        guard let navigationController = navigationControllers[.photos] else { return }
        let detailVC = DetailViewController()
        detailVC.currentPhotoData = selectedPhoto
        navigationController.pushViewController(detailVC, animated: true)
    }
}

// MARK: - FavoritesViewControllerDelegate
extension MainCoordinator: FavoritesViewControllerDelegate {
    
    func favoritesViewControllerDidSelectPhoto(_ selectedPhoto: ResultData) {
        
        guard let navigationController = navigationControllers[.favorites] else { return }
        let detailVC = DetailViewController()
        detailVC.currentPhotoData = selectedPhoto
        navigationController.pushViewController(detailVC, animated: true)
    }
}

// MARK: - enum NavControllerSettings
fileprivate enum NavControllerSettings: Int, CaseIterable {
    
    case photos, favorites
    
    var image: UIImage? {
        switch self {
        case .photos:
            return UIImage(systemName: "photo.on.rectangle.angled")
        case .favorites:
            return UIImage(systemName: "star.fill")
        }
    }
    
    var title: String {
        switch self {
        case .photos:
            return "Фото"
        case .favorites:
            return "Избранное"
        }
    }
}

