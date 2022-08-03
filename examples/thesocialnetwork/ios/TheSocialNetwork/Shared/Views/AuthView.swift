import SwiftUI

struct AuthView: View {
    
    @ObservedObject private var vm = AuthViewModel()
    @FocusState private var focused: Field?
    
    enum Field: Hashable {
        case username
        case password
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text("TSN")
                .font(.system(size: 96, weight: .heavy, design: .rounded))
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack {
                TextField("Username", text: self.$vm.username)
                    .textFieldStyle(.roundedBorder)
                    .focused(self.$focused, equals: .username)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .keyboardType(.twitter)
                
                SecureField("Password", text: self.$vm.password)
                    .textFieldStyle(.roundedBorder)
                    .focused(self.$focused, equals: .password)
            }
            .padding()
            
            if let message = vm.error {
                Text(message)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            Button("Sign In", action: { self.vm.submit() })
                .buttonStyle(.primary)
                .disabled(self.vm.invalid)
                .padding()
                
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
