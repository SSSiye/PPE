import SwiftUI

struct DetectionOverlay: View {
    let detections: [Detection]
    let size: CGSize
    var body: some View {
        ZStack {
            ForEach(detections) { det in
                let rect = det.screenRect(for: size)
                let boxColor = color(for: det.className)

                Rectangle()
                    .stroke(boxColor, lineWidth: 3)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)

                Text("\(det.className) \(Int(det.confidence * 100))%")
                    .font(.caption)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .position(x: rect.minX + 5, y: rect.minY + 5)
            }
        }
    }
    private func color(for className: String) -> Color {
           switch className {
           case "no-hardhat":
               return .red
           case "hardhat":
               return .green
           case "no-gloves":
               return .orange
           default:
               return .yellow
           }
       }
}
