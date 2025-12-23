import CoreImage
import CoreImage.CIFilterBuiltins

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

/// Generates QR code images from string content
/// Shared between iOS and watchOS
final class QRGenerator {
    private let context = CIContext()
    
    /// Generate QR code image from string
    /// - Parameter content: The string to encode in QR code
    /// - Returns: Platform-specific image or nil if generation fails
    func generate(from content: String) -> PlatformImage? {
        guard let data = content.data(using: .utf8) else { return nil }
        
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "H" // High error correction
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Scale up for clarity (QR codes are small by default)
        let scale: CGFloat = 10
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = outputImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        #if canImport(UIKit)
        return UIImage(cgImage: cgImage)
        #elseif canImport(AppKit)
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        #endif
    }
}
