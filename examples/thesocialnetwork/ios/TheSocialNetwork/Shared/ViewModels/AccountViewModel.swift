import RxSwiftCombine
import Foundation
import UIKit

class AccountViewModel: ObservableObject {
    
    @Published private(set) var loading: Bool = false
    
    /// Current server time.
    @Published var time: Date?
    
    init() {
        NetworkClient.shared
            .subscribe(to: Date.serverTime)
            .map { result in result.data }
            .catch({ _ in Just(Date?.none) })
            .assign(to: &self.$time)
    }
    
    private var cancellable: AnyCancellable?
    
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
            })
            .receive(on: RunLoop.main)
            .print()
            .sink(receiveCompletion: { res in
                switch res {
                case .finished:
                    self.loading = false
                case .failure(let err):
                    print(err.localizedDescription)
                    self.loading = false
                }
            }, receiveValue: { result in })
    }
}
