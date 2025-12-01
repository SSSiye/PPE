import SwiftUI
class CameraViewModel: ObservableObject {
    @Published var currentBuffer: CVPixelBuffer?
    private let cameraManager = CameraManager()
    init() {
        cameraManager.delegate = self
    }
    func startCamera(){
        cameraManager.startSession()
    }
    func stopCamera() {
        cameraManager.stopSession()
    }
}
extension CameraViewModel: CameraManagerDelegate {
    func cameraManager(_ manager: CameraManager, didOutput buffer: CVPixelBuffer) {
        DispatchQueue.main.async {
            self.currentBuffer = buffer
        }
    }
}
