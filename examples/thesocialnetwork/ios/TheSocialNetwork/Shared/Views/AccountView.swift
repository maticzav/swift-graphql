import PhotosUI
import SwiftUI

struct AccountView: View {
    
    @State private var isImagePickerOpen = false
    
    @ObservedObject private var vm = AccountViewModel()
    
    @EnvironmentObject private var toastc: ToastCoordinator
    
    /// DateFormatter used for formatting the server timestamp.
    private var formatter: DateFormatter
    
    /// The active user information.
    var user: User
    
    init(user: User) {
        self.user = user
        
        self.formatter = DateFormatter()
        self.formatter.timeStyle = .short
        self.formatter.dateStyle = .short
    }
    
    var body: some View {
        VStack {
            AvatarView(url: user.picture)
                .shadow(color: .black.opacity(0.25), radius: 48, x: 0, y: 16)
                .frame(width: 180, height: 182, alignment: .center)
                .padding()
                .shimmer(active: vm.loading, duration: 1)
            
            Text(user.username)
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 25)
            
            if let time = vm.time {
                Text("It's \(self.formatter.string(from: time))")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(.regularMaterial)
                    .cornerRadius(8)
            }
            
            Spacer()
            
            Button {
                self.isImagePickerOpen = true
            } label: {
                if vm.loading {
                    ProgressView()
                } else {
                    Text("Change Picture")
                }
            }
                .buttonStyle(.primary)
                .padding(.top, 24)
                .padding(.horizontal, 36)
                .frame(alignment: .bottom)
            
            Button("Logout", action: { AuthClient.logout() })
                .buttonStyle(.secondary)
                .padding(.vertical, 6)
                .padding(.horizontal, 36)
                .frame(alignment: .bottom)
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: self.$isImagePickerOpen) {
            ImagePicker { image in
                DispatchQueue.main.async {
                    toastc.toast = Toast(
                        label: "Updating Profile Picture",
                        kind: .info
                    )
                    vm.changeProfilePicture(image: image)
                }
            }
        }
    }
    
    
}

struct ProfileView_Previews: PreviewProvider {
    static var nopicture: User {
        var copy = User.preview
        copy.username = "nopic"
        copy.picture = nil
        return copy
    }
    
    static var previews: some View {
        AccountView(user: User.preview)
        AccountView(user: nopicture)
    }
}
