import SwiftUI

struct AuthView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    @FocusState private var focused: Field?
    
    enum Field: Hashable {
        case username
        case password
    }
    
    var disabled: Bool {
        username.count < 3 || password.count < 3
    }
    
    private func action() {
        AuthClient.loginOrSignup(
            username: self.username,
            password: self.password
        )
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            TextField("Username", text: self.$username)
                .focused(self.$focused, equals: .username)
                .padding()
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            SecureField("Password", text: self.$password)
                .focused(self.$focused, equals: .password)
                .padding()
            
            Button("Sign In", action: self.action)
            .buttonStyle(.primaryBordered)
            .disabled(disabled)
                
        }
        .padding()
        .onAppear {
            self.focused = .username
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
