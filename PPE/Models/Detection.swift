import Foundation
import CoreGraphics

public struct Detection: Identifiable {
    public let id = UUID()
    public let className: String
    public let confidence: Float
    public let boundingBox: CGRect

    public init(className: String, confidence: Float, boundingBox: CGRect) {
        self.className = className
        self.confidence = confidence
        self.boundingBox = boundingBox
    }

    // 화면 좌표로 변환하는 메서드 추가
    public func screenRect(for size: CGSize) -> CGRect {
        let width = boundingBox.width * size.width
        let height = boundingBox.height * size.height
        let x = boundingBox.minX * size.width
        let y = boundingBox.minY * size.height
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
