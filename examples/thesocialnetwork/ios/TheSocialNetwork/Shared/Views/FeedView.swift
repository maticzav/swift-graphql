import SwiftUI

struct FeedView: View {
    
    @State private var isComposerOpen = false
    @ObservedObject private var vm = FeedViewModel()
    @EnvironmentObject private var toastCoordinator: ToastCoordinator
    
    var body: some View {
        VStack(alignment: .leading) {
            self.header
            self.unread
            
            if vm.feed.isEmpty {
                self.placeholder
            } else {
                self.feed
            }
        }
        .sheet(isPresented: self.$isComposerOpen, content: { self.composer })
    }
    
    @ViewBuilder
    var header: some View {
        HStack(alignment: .center) {
            Text("TSN").font(.system(size: 24, weight: .bold, design: .rounded))
            Spacer()
            Button(action: { self.isComposerOpen = true }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    var feed: some View {
        List {
            ForEach(vm.feed) { item in
                PostView(
                    message: item.message,
                    author: item.sender,
                    timestamp: item.createdAt
                )
                .padding(.horizontal)
            }
            .listRowSeparatorTint(.clear)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
        }
        .listStyle(.plain)
        .refreshable { self.vm.refresh() }
    }
    
    @ViewBuilder
    var unread: some View {
        let messages = self.vm.unread == 1 ? "message" : "messages"
        if self.vm.unread > 0 {
            Text("Pull to refresh (\(self.vm.unread) \(messages)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.regularMaterial)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var placeholder: some View {
        Image(systemName: "tray").resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 48)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .foregroundColor(.gray)
    }
    
    @ViewBuilder
    var composer: some View {
        PostComposerView(message: self.$vm.message, onSubmit: {
            self.isComposerOpen = false
            self.toastCoordinator.toast = Toast(
                label: "Posting Message!",
                kind: .info
            )
            
            self.vm.post()
        })
    }
}

struct PostComposerView: View {
    
    /// Content of the post.
    @Binding var message: String
    
    /// Function that's called when the user wants to share the post.
    var onSubmit: () -> Void
    
    /// User focus manager.
    @FocusState private var focused: Field?
    
    enum Field {
        case none
        case post
    }
    
    init(message: Binding<String>, onSubmit: @escaping () -> Void) {
        self._message = message
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Capsule()
                    .frame(width: 36, height: 4)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, -4)
            
            
            ZStack(alignment: .topLeading) {
                Text("I am thinking about ...").font(self.font)
                    .foregroundColor(.gray)
                    .opacity(self.message.isEmpty ? 1 : 0)
                    .padding(.top, 8)
                
                TextEditor(text: self.$message).font(self.font)
                    .opacity(self.message.isEmpty ? 0.25 : 1)
                    .focused(self.$focused, equals: .post)
            }
            .padding()
            .frame(minHeight: 240)
            .onTapGesture {
                if case .post = self.focused {
                    self.focused = Field.none
                } else {
                    self.focused = Field.post
                }
            }
            
            Spacer()
            HStack {
                Spacer()
                Button(action: self.onSubmit) {
                    Image(systemName: "paperplane.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                .disabled(self.message.count <= 3)
            }
            .padding()
        }
        .padding()
        .onAppear {
            self.focused = .post
        }
    }
    
    private var font: Font = .system(size: 24, weight: .semibold, design: .rounded)
}



// MARK: - Previews

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
        PostComposerView(message: .constant("")) {
            
        }
    }
}
