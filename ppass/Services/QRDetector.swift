import Vision
import UIKit

/// Detects and decodes QR codes from images using Vision framework
final class QRDetector {
    
    enum DetectionError: LocalizedError {
        case invalidImage
        case noQRCodeFound
        case processingFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "Invalid image"
            case .noQRCodeFound:
                return "No QR code found"
            case .processingFailed(let error):
                return "Processing failed: \(error.localizedDescription)"
            }
        }
    }
    
    struct DetectionResult {
        let content: String
        let boundingBox: CGRect
    }
    
    /// Detect QR code in image
    /// - Parameter image: UIImage to scan
    /// - Returns: Detection result with content and bounding box
    func detect(in image: UIImage) async throws -> DetectionResult {
        guard let cgImage = image.cgImage else {
            throw DetectionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: DetectionError.processingFailed(error))
                    return
                }
                
                guard let observations = request.results as? [VNBarcodeObservation],
                      let first = observations.first(where: { $0.symbology == .qr }),
                      let content = first.payloadStringValue else {
                    continuation.resume(throwing: DetectionError.noQRCodeFound)
                    return
                }
                
                let result = DetectionResult(
                    content: content,
                    boundingBox: first.boundingBox
                )
                continuation.resume(returning: result)
            }
            
            request.symbologies = [.qr]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: DetectionError.processingFailed(error))
            }
        }
    }
}
