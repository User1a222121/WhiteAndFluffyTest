import Foundation

struct PhotoData: Codable {
    
    var total: Int = 0
    var page: Int = 0
    var results: [ResultData]
    
    enum CodingKeys: String, CodingKey {
        case total
        case results
    }
}

struct ResultData: Codable {
    
    var resultDescription: String?
    let id: String
    var createdAt: String
    var downloads: Int?
    let likedByUser: Bool
    let likes: Int?
    var urls: Urls
    var user: User
    
    enum CodingKeys: String, CodingKey {
        case resultDescription = "description"
        case id
        case createdAt = "created_at"
        case downloads
        case likedByUser = "liked_by_user"
        case likes
        case urls
        case user
    }
}

struct Urls: Codable {

    var full: String
    var thumb: String
}

struct Location: Codable {

    var city: String
    var country: String
}

struct User: Codable {

    var name: String
    var location: String?
}
