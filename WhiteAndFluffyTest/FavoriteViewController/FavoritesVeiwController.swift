import UIKit

protocol FavoritesViewControllerDelegate: AnyObject {
    
  func favoritesViewControllerDidSelectPhoto(_ selectedPhoto: ResultData)
}

class FavoritesViewController: UIViewController {
    
    // MARK: - Views
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(FavoritesCell.self, forCellReuseIdentifier: FavoritesCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Properties
    private let networkService = NetworkService()
    var favoritesPhotoData: [ResultData] = []
    weak var delegate: FavoritesViewControllerDelegate?
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.favoritesPhotoData.removeAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        networkService.requestLikedPhotos { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.favoritesPhotoData = data
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error received requesting data: \(error.localizedDescription)")
                let alertVC = UIAlertController(
                            title: "Error",
                            message: "Error connecting to the server",
                            preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertVC.addAction(action)
                self?.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - func
    private func setupUI() {
    
        self.view.backgroundColor = .white
        self.view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

// MARK: - extension UITableViewDataSource, UITableViewDelegate
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesPhotoData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesCell.reuseId,
                                                    for: indexPath) as? FavoritesCell {
            
            cell.setCell(with: favoritesPhotoData[indexPath.row])
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = favoritesPhotoData[indexPath.row]
        delegate?.favoritesViewControllerDidSelectPhoto(photo)
    }
}

