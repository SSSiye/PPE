import SwiftUI
struct PixelBufferView: UIViewRepresentable {
    var pixelBuffer: CVPixelBuffer?

    func makeUIView(context: Context) -> CameraPreview {
        return CameraPreview()
    }

    func updateUIView(_ uiView: CameraPreview, context: Context) {
        uiView.update(pixelBuffer: pixelBuffer)
    }
}

class CameraPreview: UIView {
    private let imageView = UIImageView()
    private let context = CIContext()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    func update(pixelBuffer: CVPixelBuffer?) {
        guard let buffer = pixelBuffer else { return }
        let ciImage = CIImage(cvPixelBuffer: buffer)
            .oriented(.right)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                self.imageView.image = uiImage
            }
        }
    }
}
