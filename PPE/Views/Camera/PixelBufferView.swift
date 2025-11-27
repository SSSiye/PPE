import SwiftUI
import AVFoundation

struct PixelBufferView: UIViewRepresentable {
    var pixelBuffer: CVPixelBuffer?

    func makeUIView(context: Context) -> CameraPreviewView {
        return CameraPreviewView()
    }

    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        uiView.update(pixelBuffer: pixelBuffer)
    }
}

class CameraPreviewView: UIView {
    private let imageView = UIImageView()
    private let context = CIContext()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(pixelBuffer: CVPixelBuffer?) {
        guard let buffer = pixelBuffer else { return }
        let ciImage = CIImage(cvPixelBuffer: buffer)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                self.imageView.image = uiImage
            }
        }
    }
}
