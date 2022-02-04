import UIKit
import Kingfisher

class FavoritesCell: UITableViewCell {
    
    // MARK: - Properties
    static let reuseId = "FavoritesCell"
    private var downloadTask: DownloadTask?
    
    // MARK: - Views
    
    private let nameAphtor: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private let photo: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        image.backgroundColor = .lightGray
        image.contentMode = .scaleAspectFill
        
        return image
    }()
    
    // init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setConstraints()
      }
    
    required init?(coder _: NSCoder) {
             fatalError("init(coder:) has not been implemented")
    }
    
    // prepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        photo.image = nil
        downloadTask?.cancel()
    }
    
    
    // MARK: func
    func setCell(with model: ResultData) {
        
        nameAphtor.text = model.user.name
        guard let url = URL(string: model.urls.thumb) else { return }
        photo.kf.indicatorType = .activity
        downloadTask = KF.url(url)
            .set(to: photo)
        
        guard let urlFullPhoto = URL(string: (model.urls.full)) else { return }
        let resource = ImageResource(downloadURL: urlFullPhoto)
        KingfisherManager.shared.retrieveImage(with: resource) { image in }
    }
    
    // MARK: - func
    private func setupUI() {
        
        contentView.addSubview(photo)
        contentView.addSubview(nameAphtor)
    }
    
    private func setConstraints() {
        
        NSLayoutConstraint.activate([
            photo.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            photo.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            photo.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            photo.widthAnchor.constraint(equalTo: photo.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameAphtor.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameAphtor.leadingAnchor.constraint(equalTo: photo.trailingAnchor, constant: 10),
            nameAphtor.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
}

