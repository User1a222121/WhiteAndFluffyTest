import UIKit

protocol MainViewControllerDelegate: AnyObject {
    
  func mainViewControllerDidSelectPhoto(_ selectedPhoto: ResultData)
}

class MainViewController: UIViewController, UISearchControllerDelegate {
    
    // MARK: - Views
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search photos"
        searchController.searchBar.autocapitalizationType = .allCharacters
        return searchController
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        collectionView.register(MainCell.self, forCellWithReuseIdentifier: MainCell.reuseId)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Properties
    private let networkService = NetworkService()
    var resultData: [ResultData] = []
    private var filterResultData: [ResultData] = []
    weak var delegate: MainViewControllerDelegate?
    private let itemsPerRow: CGFloat = 1
    private let sectionInsets = UIEdgeInsets(
      top: 10.0,
      left: 20.0,
      bottom: 10.0,
      right: 20.0)
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
        
        networkService.requestRandomPhotos(page: 1) { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.resultData = data.results
                self?.collectionView.reloadData()
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
    
    // MARK: - func setup
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
       }
    
    private func setupUI() {
        
        self.view.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
    }
    
    private func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: 10,
                                           bottom: 0,
                                           right: 10)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cellWidthHeightConstant: CGFloat = UIScreen.main.bounds.width * 0.2
        layout.itemSize = CGSize(width: cellWidthHeightConstant, height: cellWidthHeightConstant)
        
        return layout
    }
    
    // MARK: - func
    private func fetchPhoto(ofIndex index: Int) {

        guard index % 10 == 0 else { return }
        let pageNumber = (index / 10)
        guard resultData.count/10 == pageNumber else { return }
        networkService.requestRandomPhotos(page: pageNumber + 1) { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.resultData.append(contentsOf: data.results)
                self?.collectionView.reloadData()
                
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
}

// MARK: - extension UICollectionViewDelegate, UICollectionViewDataSource
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filterResultData.count
        } else {
            return resultData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCell.reuseId, for: indexPath) as? MainCell {
            
            
            let data: ResultData
            if isFiltering {
                data = filterResultData[indexPath.item]
            } else {
                data = resultData[indexPath.item]
            }
            cell.setCell(with: data)

            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isFiltering {
            let photo = filterResultData[indexPath.item]
            delegate?.mainViewControllerDidSelectPhoto(photo)
        } else {
            let photo = resultData[indexPath.item]
            delegate?.mainViewControllerDidSelectPhoto(photo)
        }
    }
}

// MARK: - extension UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath
      ) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
      }
      
      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          insetForSectionAt section: Int
      ) -> UIEdgeInsets {
        return sectionInsets
      }
      
      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int
      ) -> CGFloat {
        return sectionInsets.left
      }
}

// MARK: extension UISearchResultsUpdating
extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        networkService.requestSearchPhotos(query: searchController.searchBar.text!) { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.filterResultData = data.results
                self?.collectionView.reloadData()
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
}

// MARK: extension UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }
}

// MARK: Extension UICollectionViewDataSourcePrefetching
extension MainViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
                self.fetchPhoto(ofIndex: indexPath.item + 7)
        }
    }
}




