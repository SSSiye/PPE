import SwiftUI
import AVFoundation
import Vision

class CameraViewModel: ObservableObject {
    @Published var currentBuffer: CVPixelBuffer?
    @Published var detections: [Detection] = []

    private let cameraManager = CameraManager()
    private var isProcessing = false

    init() {
        cameraManager.delegate = self
        
        // 모델 로드 상태 확인
        print("YOLO 모델 로드 상태:", YOLOModelManager.shared.self)
    }

    func startCamera() {
        cameraManager.startSession()
    }

    func stopCamera() {
        cameraManager.stopSession()
    }
    
    private func processBuffer(_ pixelBuffer: CVPixelBuffer) {
        guard !isProcessing else { return }
        isProcessing = true

        YOLOModelManager.shared.predict(pixelBuffer: pixelBuffer) { [weak self] detections in
            DispatchQueue.main.async {
                self?.detections = detections
                
                // 디버깅: detections 확인
                if detections.isEmpty {
                    print("YOLO 결과 비어있음")
                } else {
                    for det in detections {
                        print("Detected:", det.className, det.confidence, det.boundingBox)
                    }
                }
//                self?.detections = [
//                                Detection(className: "Helmet", confidence: 0.9, boundingBox: CGRect(x: 0.2, y: 0.3, width: 0.2, height: 0.2)),
//                                Detection(className: "Gloves", confidence: 0.85, boundingBox: CGRect(x: 0.5, y: 0.4, width: 0.2, height: 0.2))
//                            ]
                self?.isProcessing = false
            }
        }
    }
}

extension CameraViewModel: CameraManagerDelegate {
    func cameraManager(_ manager: CameraManager, didOutput buffer: CVPixelBuffer) {
        DispatchQueue.main.async {
            self.currentBuffer = buffer
        }
        processBuffer(buffer)
    }
}
