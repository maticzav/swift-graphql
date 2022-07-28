import PhotosUI
import SwiftUI

/// Presents an image picker or camera.
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    
    /// Callback function that's called when user selects an image.
    let completion: (_ selectedImage: UIImage) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selection = .default
        configuration.selectionLimit = 1
        
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_: PHPickerViewController, context _: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    internal class Coordinator: PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let image = results.first else {
                return
            }
            
            image.itemProvider.loadObject(ofClass: UIImage.self) { selectedImage, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let uiImage = selectedImage as? UIImage else {
                    print("unable to unwrap image as UIImage")
                    return
                }
                
                self.parent.completion(uiImage)
            }
            
        }
    }
}

// MARK: - Preview

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePicker() { selectedImage in
            ()
        }
    }
}
