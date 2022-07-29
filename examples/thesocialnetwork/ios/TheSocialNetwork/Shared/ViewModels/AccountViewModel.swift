import Combine
import Foundation
import UIKit

class AccountViewModel: ObservableObject {
    
    @Published private(set) var loading: Bool
    
    /// Current server time.
    @Published var time: Date?
    
    private var cancellable: AnyCancellable?
    
    init() {
        self.loading = false
        
        NetworkClient.shared
            .subscribe(to: Date.serverTime)
            .map { result in
                guard case let .ok(date) = result.result else {
                    return nil
                }

                return date
            }
            .assign(to: &self.$time)
    }
    
    /// Method that starts the upload of a profile picture.
    func changeProfilePicture(image: UIImage) {
        self.loading = true
        guard let data = image.jpegData(compressionQuality: 0.3) else {
            self.loading = false
            return
        }
        
        self.cancellable = CDNClient.upload(data: data, extension: "jpeg", contentType: "image/jpeg")
            .flatMap({ file in
                NetworkClient.shared.mutate(User.changeProfilePicture(file: file.id))
                    .eraseToAnyPublisher()
            })
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { res in             
                self.loading = false
            }, receiveValue: { result in
                ()
            })
    }
}
