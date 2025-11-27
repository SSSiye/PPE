import SwiftUI
struct CameraView: View {
    @StateObject private var cameraVM = CameraViewModel()

    var body: some View {
        PixelBufferView(pixelBuffer: cameraVM.currentBuffer)
            .onAppear {
                cameraVM.startCamera()
            }
            .onDisappear {
                cameraVM.stopCamera()
            }
    }
}
