import Foundation

enum NetworkError: Error {
    case errorInRequest
    case noData
    case decodeError
}

class NetworkService {
    
    //MARK: - Propirties
    private let userName = "user1a"
    private let authorizationCode = "k96LKmpLP-i6yU953ck5VGh0GODShrYbKfowTLYPpLY"
    
    func requestRandomPhotos(page: Int, responseData: @escaping (Result<PhotoData, NetworkError>) -> Void) {
        
        guard let url = URL(string: "https://api.unsplash.com/search/photos?page=\(page)&query=random") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authorizationCode)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error ) in
            DispatchQueue.main.async {
                if let error = error {
                    responseData(.failure(.errorInRequest))
                    print(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    responseData(.failure(.noData))
                    return
                }
                
                let decoder = JSONDecoder()
                do {
                    var decoderResult = try decoder.decode(PhotoData.self, from: data)

                    decoderResult.page = page
                    responseData(.success(decoderResult))
                } catch {
                    responseData(.failure(.decodeError))
                    print("failed to convert \(error)")
                }
            }
        }
        task.resume()
    }
    
    // requestSearchPhotos func
    func requestSearchPhotos(query: String, responseData: @escaping (Result<PhotoData, NetworkError>) -> Void) {
        
        guard let url = URL(string: "https://api.unsplash.com/search/photos?&query=\(query)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authorizationCode)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error ) in
            DispatchQueue.main.async {
                if let error = error {
                    responseData(.failure(.errorInRequest))
                    print(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    responseData(.failure(.noData))
                    return
                }
                
                let decoder = JSONDecoder()
                do {
                    let decoderResult = try decoder.decode(PhotoData.self, from: data)
                    responseData(.success(decoderResult))
                } catch {
                    responseData(.failure(.decodeError))
                    print("failed to convert \(error)")
                }
            }
        }
        task.resume()
    }
    
    // requestLikedPhotos func
    func requestLikedPhotos(responseData: @escaping (Result<[ResultData], NetworkError>) -> Void) {
        guard let url = URL.with(string: "/users/\(userName)/likes") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authorizationCode)", forHTTPHeaderField: "Authorization")

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    responseData(.failure(.errorInRequest))
                    print(error.localizedDescription)
                    return
                }
                guard let data = data else {
                    responseData(.failure(.noData))
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let decoderResult = try decoder.decode([ResultData].self, from: data)
                    responseData(.success(decoderResult))
                } catch {
                    responseData(.failure(.decodeError))
                    print("failed to convert \(error)")
                }
            }
        }
        task.resume()
    }
    
    // likePhoto func
    func likePhoto(id: String) {
        guard let url = URL.with(string: "/photos/\(id)/like") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authorizationCode)", forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { _, response, error in
            
            if let response = response as? HTTPURLResponse, response.statusCode != 201 {
                print(error?.localizedDescription ?? "error likePhoto func")
            }
        }
        task.resume()
    }
    
    // unlikePhoto func
    func unlikePhoto(id: String) {
        guard let url = URL.with(string: "/photos/\(id)/like") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(authorizationCode)", forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { _, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                print(error?.localizedDescription ?? "error unlikePhoto func")
            }
        }
        task.resume()
    }
}

//MARK: - extendion URL
extension URL {
    private static var baseUrl = "https://api.unsplash.com/"
    
    static func with(string: String) -> URL? {
        return URL(string: "\(baseUrl)\(string)")
    }
}
