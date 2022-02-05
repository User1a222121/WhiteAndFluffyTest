import UIKit
import Kingfisher

class MainCell: UICollectionViewCell {
    
    // MARK: - views
    lazy var photo: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.systemGray.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Properties
    static let reuseId = "CustomCell"
    private var downloadTask: DownloadTask?

    // MARK: prepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        photo.image = nil
        downloadTask?.cancel()
    }
    
    // init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // layoutSubviews
    override func layoutSubviews() {
        setupUI()
    }
    
    // MARK: - func
    func setCell(with model: ResultData) {
        guard let url = URL(string: model.urls.thumb) else { return }
        photo.kf.indicatorType = .activity
        downloadTask = KF.url(url)
            .set(to: photo)
    }
        
    private func setupUI() {
        
        self.contentView.addSubview(photo)
        
        NSLayoutConstraint.activate([
            photo.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            photo.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),
            photo.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 5),
            photo.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -5)
        ])
    }
}
