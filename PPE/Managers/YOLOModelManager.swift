import Foundation
import Vision
import CoreML
import AVFoundation

final class YOLOModelManager {

    static let shared = YOLOModelManager()

    var confidenceThreshold: Float = 0.25
    private var vnModel: VNCoreMLModel?

    private init() {
        loadModel()
    }

    private func loadModel() {
        if vnModel == nil {
            if let model = tryLoadGeneratedModelClass() {
                vnModel = model
                return
            }
        }

        if vnModel == nil {
            if let model = tryLoadModelFromBundle() {
                vnModel = model
                return
            }
        }
    }

    private func tryLoadGeneratedModelClass() -> VNCoreMLModel? {
        let possibleClassNames = ["Best", "best"]

        for name in possibleClassNames {
            if let cls = NSClassFromString(name) as? NSObject.Type {
                let instance = cls.init()
                if let mlModel = (instance as AnyObject).value(forKey: "model") as? MLModel {
                    do {
                        let vn = try VNCoreMLModel(for: mlModel)
                        return vn
                    } catch { }
                }
            }
        }
        return nil
    }

    private func tryLoadModelFromBundle() -> VNCoreMLModel? {
        let bundle = Bundle.main
        let candidates = [
            ("best", "mlmodelc"),
            ("model", "mlmodelc"),
            ("best", "mlpackage")
        ]

        for (name, ext) in candidates {
            if let url = bundle.url(forResource: name, withExtension: ext) {
                do {
                    let mlModel: MLModel
                    if ext == "mlpackage" {
                        let modelInside = url.appendingPathComponent("Data/com.apple.CoreML/model.mlmodel")
                        if FileManager.default.fileExists(atPath: modelInside.path) {
                            let compiledURL = try MLModel.compileModel(at: modelInside)
                            mlModel = try MLModel(contentsOf: compiledURL)
                        } else {
                            let compiledURL = try MLModel.compileModel(at: url)
                            mlModel = try MLModel(contentsOf: compiledURL)
                        }
                    } else {
                        mlModel = try MLModel(contentsOf: url)
                    }
                    let vn = try VNCoreMLModel(for: mlModel)
                    return vn
                } catch { }
            }
        }

        let paths = bundle.paths(forResourcesOfType: "mlmodelc", inDirectory: nil)
        if !paths.isEmpty {
            for p in paths {
                let url = URL(fileURLWithPath: p)
                do {
                    let mlModel = try MLModel(contentsOf: url)
                    let vn = try VNCoreMLModel(for: mlModel)
                    return vn
                } catch { }
            }
        }


        return nil
    }

    func predict(pixelBuffer: CVPixelBuffer, completion: @escaping ([Detection]) -> Void) {
        print("📌 predict() 호출됨")
        guard let vnModel = vnModel else {
            print("❌ vnModel is nil — 모델이 로드되지 않음")
            DispatchQueue.main.async { completion([]) }
            return
        }
        print("✅ vnModel 정상 로드됨")

        let request = VNCoreMLRequest(model: vnModel) { [weak self] request, _ in
            var detections: [Detection] = []
            let results = request.results ?? []
            print("📌 Vision raw results count:", results.count)
            for (i, r) in results.enumerated() {
                print("🔍 result[\(i)] 타입:", type(of: r))
            }
            
            for res in results {
                if let obj = res as? VNRecognizedObjectObservation {
                    let rawBox = obj.boundingBox
                    let box = CGRect(
                        x: rawBox.origin.x,
                        y: 1 - rawBox.origin.y - rawBox.size.height,
                        width: rawBox.size.width,
                        height: rawBox.size.height
                    )

                    if let top = obj.labels.first {
                        let name = top.identifier
                        let conf = top.confidence
                        if conf >= (self?.confidenceThreshold ?? 0.0) {
                            detections.append(Detection(className: name, confidence: Float(conf), boundingBox: box))
                        }
                    } else {
                        let conf = obj.confidence
                        if conf >= (self?.confidenceThreshold ?? 0.0) {
                            detections.append(Detection(className: "unknown", confidence: Float(conf), boundingBox: box))
                        }
                    }
                }
            }
            print("📦 최종 detections 개수:", detections.count)
            for det in detections {
                print("➡️ DETECTION:", det.className, det.confidence, det.boundingBox)
            }

            DispatchQueue.main.async {
                completion(detections)
            }
        }

        request.imageCropAndScaleOption = .scaleFit
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)

        DispatchQueue.global(qos: .userInitiated).async {
            do { try handler.perform([request]) }
            catch { DispatchQueue.main.async { completion([]) } }
        }
    }
}
