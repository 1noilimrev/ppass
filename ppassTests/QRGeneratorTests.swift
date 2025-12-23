import XCTest
@testable import ppass

final class QRGeneratorTests: XCTestCase {
    
    private var generator: QRGenerator!
    private var detector: QRDetector!
    
    override func setUp() {
        super.setUp()
        generator = QRGenerator()
        detector = QRDetector()
    }
    
    override func tearDown() {
        generator = nil
        detector = nil
        super.tearDown()
    }
    
    func testGenerate_withValidContent_returnsImage() {
        // #given
        let content = "test-content-123"
        
        // #when
        let image = generator.generate(from: content)
        
        // #then
        XCTAssertNotNil(image)
        XCTAssertGreaterThan(image?.size.width ?? 0, 0)
        XCTAssertGreaterThan(image?.size.height ?? 0, 0)
    }
    
    func testGenerate_withEmptyContent_returnsImage() {
        // #given
        let content = ""
        
        // #when
        let image = generator.generate(from: content)
        
        // #then
        XCTAssertNotNil(image)
    }
    
    func testGenerate_roundTrip_decodesOriginalContent() async throws {
        // #given
        let originalContent = "round-trip-test-payload-456"
        
        // #when
        guard let qrImage = generator.generate(from: originalContent) else {
            XCTFail("Failed to generate QR image")
            return
        }
        let result = try await detector.detect(in: qrImage)
        
        // #then
        XCTAssertEqual(result.content, originalContent)
    }
    
    func testGenerate_withURLContent_roundTripWorks() async throws {
        // #given
        let urlContent = "https://example.com/path?query=value&foo=bar"
        
        // #when
        guard let qrImage = generator.generate(from: urlContent) else {
            XCTFail("Failed to generate QR image")
            return
        }
        let result = try await detector.detect(in: qrImage)
        
        // #then
        XCTAssertEqual(result.content, urlContent)
    }
    
    func testGenerate_withUnicodeContent_roundTripWorks() async throws {
        // #given
        let unicodeContent = "한글 테스트 🎉"
        
        // #when
        guard let qrImage = generator.generate(from: unicodeContent) else {
            XCTFail("Failed to generate QR image")
            return
        }
        let result = try await detector.detect(in: qrImage)
        
        // #then
        XCTAssertEqual(result.content, unicodeContent)
    }
}
