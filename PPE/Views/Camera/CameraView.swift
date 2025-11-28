import SwiftUI
struct CameraView: View {
    @StateObject private var cameraVM = CameraViewModel()

    var body: some View {
        PixelBufferView(pixelBuffer: cameraVM.currentBuffer)
            .frame(width: UIScreen.main.bounds.width,
                   height: UIScreen.main.bounds.height)

            .onAppear {
                cameraVM.startCamera()
            }
            .onDisappear {
                cameraVM.stopCamera()
            }
    }
}
