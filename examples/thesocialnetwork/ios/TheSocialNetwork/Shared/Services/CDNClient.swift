import RxSwiftCombine
import Foundation

enum CDNClient {
    
    /// Uploads a given file to the CDN and returns the ID that may be used to identify it.
    static func upload(data: Data, extension ext: String, contentType: String) -> AnyPublisher<File, Error> {
        NetworkClient.shared.mutate(SignedURL.getSignedURL(extension: ext, contentType: contentType))
            .flatMap { result -> AnyPublisher<File, Error> in
                
                guard let url = result.data else {
                    return Fail<File, Error>(error: CDNError.badSignedURL)
                }
                
                let file = File(id: url.id, url: url.fileURL)
                
                var request = URLRequest(url: url.uploadURL, cachePolicy: .reloadIgnoringLocalCacheData)
                request.httpMethod = "PUT"
                request.setValue(contentType, forHTTPHeaderField: "Content-Type")
                
                let upload = URLSession.shared.uploadTaskPublisher(with: request, from: data)
                
                return upload.map { _ in file }
            }
    }
}

extension URLSession {
    
    /// Creates a publisher that emits `true` when the file was successfully uploaded to a given URL.
    func uploadTaskPublisher(with request: URLRequest, from data: Data) -> AnyPublisher<Bool, Error> {
        let publisher = Future<Bool, Error> { promise in
            let task = self.uploadTask(with: request, from: data) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                    promise(.failure(CDNError.badResponseCode))
                    return
                }
                
                promise(.success(true))
            }
            
            task.resume()
        }
        
        return publisher
    }
}

enum CDNError: Error {
    case badResponseCode
    case badSignedURL
}
