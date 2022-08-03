import SwiftUI

struct AvatarView: View {
    var url: URL?
    
    var body: some View {
        if let url = self.url {
            AsyncImage(url: url) { image in
                image.resizable()
            } placeholder: { self.avatar.shimmer(active: true, duration: 1) }
                .mask { Circle() }
        } else {
            self.avatar
        }
    }
    
    @ViewBuilder
    private var avatar: some View {
        GeometryReader { proxy in
            Image(systemName: "person.fill")
                .resizable()
                .foregroundColor(Color.white)
                .padding(proxy.size.height / 4)
                .background(Circle().foregroundColor(Color.gray))
        }
    }
}

// MARK: - Previews

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 16) {
            AvatarView()
                .frame(width: 52, height: 52)
            AvatarView(url: URL(string: "https://google.com")!)
                .frame(width: 52, height: 52)
            AvatarView(url: URL(string: "https://ak.picdn.net/contributors/3038285/avatars/thumb.jpg?t=1596662706493")!)
                .frame(width: 52, height: 52)
        }
    }
}
