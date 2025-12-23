import XCTest
@testable import ppass

final class QRDetectorTests: XCTestCase {
    
    private var detector: QRDetector!
    private var generator: QRGenerator!
    
    override func setUp() {
        super.setUp()
        detector = QRDetector()
        generator = QRGenerator()
    }
    
    override func tearDown() {
        detector = nil
        generator = nil
        super.tearDown()
    }
    
    func testDetectQRCode_withValidQRImage_returnsContent() async throws {
        // #given
        let expectedContent = "https://example.com/test"
        guard let qrImage = generator.generate(from: expectedContent) else {
            XCTFail("Failed to generate QR image")
            return
        }
        
        // #when
        let result = try await detector.detect(in: qrImage)
        
        // #then
        XCTAssertEqual(result.content, expectedContent)
        XCTAssertFalse(result.boundingBox.isEmpty)
    }
    
    func testDetectQRCode_withNoQRImage_throwsError() async {
        // #given
        let plainImage = createPlainImage()
        
        // #when
        do {
            _ = try await detector.detect(in: plainImage)
            // #then
            XCTFail("Expected error to be thrown")
        } catch {
            // #then
            XCTAssertTrue(error is QRDetector.DetectionError)
        }
    }
    
    func testDetectQRCode_withComplexContent_decodesCorrectly() async throws {
        // #given
        let complexContent = "WIFI:T:WPA;S:MyNetwork;P:MyPassword;;"
        guard let qrImage = generator.generate(from: complexContent) else {
            XCTFail("Failed to generate QR image")
            return
        }
        
        // #when
        let result = try await detector.detect(in: qrImage)
        
        // #then
        XCTAssertEqual(result.content, complexContent)
    }
    
    // MARK: - Helpers
    
    private func createPlainImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
