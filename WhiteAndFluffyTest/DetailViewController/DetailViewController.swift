import UIKit
import Kingfisher

class DetailViewController: UIViewController {
    
    deinit {
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    
    // MARK: - views
    var imageOutlet: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        image.backgroundColor = .lightGray
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let createdAt: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let location: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let downloads: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let addFavoritButton : UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.addTarget(self, action: #selector(likePhoto), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    var currentPhotoData: ResultData?
    private var downloadTask: DownloadTask?
    private let networkService = NetworkService()
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScreen()
        configureUI()
        setUIConstraints()
    }
    
    // MARK: func
    func setupScreen() {
        
        guard let currentPhotoData = self.currentPhotoData else { return }
        guard let url = URL(string: (currentPhotoData.urls.full)) else { return }
        imageOutlet.kf.indicatorType = .activity
        downloadTask = KF.url(url)
            .set(to: imageOutlet)
        
        name.text = "Автор - \(currentPhotoData.user.name)"
        location.text = "Локация - \(String(describing: currentPhotoData.user.location ?? "нет информации"))"
        downloads.text = "Кол-во загрузок - \(String(describing: currentPhotoData.downloads ?? 0))"
        createdAt.text = "Дата создания - \(currentPhotoData.createdAt.dropLast(15))"
        if !currentPhotoData.likedByUser {
            self.addFavoritButton.setTitle("Добавить в избранное", for: .normal)
        } else {
            self.addFavoritButton.setTitle("Удалить из избранного", for: .normal)
        }
    }
    
    @objc private func likePhoto(){
        guard let currentPhotoData = self.currentPhotoData else { return }
        if currentPhotoData.likedByUser {
            self.addFavoritButton.setTitle("Добавить в избранное", for: .normal)
            networkService.unlikePhoto(id: currentPhotoData.id)
        } else {
            self.addFavoritButton.setTitle("Удалить из избранного", for: .normal)
            networkService.likePhoto(id: currentPhotoData.id)
        }
    }
    
    func configureUI() {
        
        view.backgroundColor = .systemBackground
        view.addSubview(imageOutlet)
        view.addSubview(name)
        view.addSubview(location)
        view.addSubview(createdAt)
        view.addSubview(downloads)
        view.addSubview(addFavoritButton)
    }
    
    private func setUIConstraints() {
        
        NSLayoutConstraint.activate([
            imageOutlet.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            imageOutlet.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            imageOutlet.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            imageOutlet.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)
        ])
        
        NSLayoutConstraint.activate([
            name.topAnchor.constraint(equalTo: imageOutlet.bottomAnchor, constant: 15),
            name.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            name.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
        ])
        
        NSLayoutConstraint.activate([
            location.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8),
            location.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            location.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
        ])
        
        NSLayoutConstraint.activate([
            createdAt.topAnchor.constraint(equalTo: location.bottomAnchor, constant: 8),
            createdAt.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            createdAt.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        
        ])

        NSLayoutConstraint.activate([
            downloads.topAnchor.constraint(equalTo: createdAt.bottomAnchor, constant: 8),
            downloads.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            downloads.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            addFavoritButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addFavoritButton.topAnchor.constraint(equalTo: downloads.bottomAnchor, constant: 20),
            addFavoritButton.heightAnchor.constraint(equalToConstant: 40),
            addFavoritButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
}
