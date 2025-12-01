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
}
