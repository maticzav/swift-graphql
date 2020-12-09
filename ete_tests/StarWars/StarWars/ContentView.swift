import SwiftUI
import SwiftGraphQL


/* View */

struct ContentView: View {
    @ObservedObject private var model = Model()
    
    var body: some View {
        NavigationView {
            VStack {
                /* Greeting */
                HStack {
                    Text(model.data.greeting)
                        .font(.headline)
                    Spacer()
                    Text(model.data.character)
                }
                .padding()
                /* Time */
                HStack {
                    Text(model.data.time?.value ?? "What's the time??")
                        .font(.headline)
                    Spacer()
                    Text("\(model.data.time?.raw ?? 0)")
                        .font(.headline)
                }
                .padding()
                /* Authorization */
                HStack {
                    Text(model.data.whoami)
                        .font(.headline)
                    Spacer()
                }
                .padding()
                /* Characters */
                HStack {
                    Text("Characters")
                        .font(Font.title)
                    Spacer()
                }
                .padding()
                List {
                    ForEach(model.data.characters, id: \.id) { character in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(character.name)
                            Text(character.message)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("StarWars 🌌")
        }
        .onAppear(perform: {
            model.fetch()
        })
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
