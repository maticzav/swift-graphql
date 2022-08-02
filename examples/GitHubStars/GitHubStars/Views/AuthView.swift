import SwiftUI

struct AuthView: View {
    @State private var token: String = ""
    
    var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 92, height: 92)
                .padding(.vertical, 160)
            
            VStack(alignment: .leading) {
                Text("Personal Access Token").font(.system(size: 14))
                
                TextField("Personal Access Token", text: self.$token)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.bottom)
            
            
                
            
            Button("Submit") {
                AuthClient.login(token: self.token)
            }
            .buttonStyle(.borderedProminent)
            .disabled(token.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Previews

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
