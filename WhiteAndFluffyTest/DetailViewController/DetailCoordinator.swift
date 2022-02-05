import UIKit

class DetailCoordinator: CoordinatorProtocol {
    
    private let presenter: UINavigationController
    private var detailViewController: DetailViewController?
    private let photo: ResultData
    
    // init
    init(presenter: UINavigationController,
         photo: ResultData) {

        self.photo = photo
        self.presenter = presenter

    }
    
    // func
    func start() {
        
        let detailViewController = DetailViewController()
        detailViewController.currentPhotoData = photo
        presenter.pushViewController(detailViewController, animated: true)
        self.detailViewController = detailViewController
    }
}

