import SwiftUI
struct CameraView: View {
    @StateObject private var cameraVM = CameraViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                PixelBufferView(pixelBuffer: cameraVM.currentBuffer)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .onAppear {
                        cameraVM.startCamera()
                    }
                    .onDisappear {
                        cameraVM.stopCamera()
                    }

                DetectionOverlay(detections: cameraVM.detections, size: geo.size)
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
    }
}
