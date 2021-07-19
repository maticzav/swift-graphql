import SwiftGraphQL
import SwiftUI

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
                HStack {
                    Text("Subscription number")
                    Text("\(model.subscriptionData)")
                    Spacer()
                }.padding([.horizontal, .bottom])
            }
            .navigationTitle("StarWars 🌌")
        }
        .onAppearOrEnterForeground {
            model.fetch()
            model.startListening()
        }
        .onDisappearOrEnterBackground {
            model.stopListening()
        }
    }
}

extension View {
    func onAppearOrEnterForeground(perform block: @escaping () -> Void) -> some View {
        self.onAppear(perform: block)
            .on(UIApplication.willEnterForegroundNotification, perform: { _ in block() })
    }
    
    func onDisappearOrEnterBackground(perform block: @escaping () -> Void) -> some View {
        self.onDisappear(perform: block)
            .on(UIApplication.willResignActiveNotification, perform: { _ in block() })
    }
    
    func on(_ notification: Notification.Name,
            nc: NotificationCenter = NotificationCenter.default,
            perform block: @escaping (Notification) -> Void) -> some View {
        self.onReceive(nc.publisher(for: notification), perform: block)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
