import XCTest
@testable import ppass

final class LogStoreTests: XCTestCase {
    
    private var logStore: LogStore!
    
    override func setUp() {
        super.setUp()
        // Clear any existing data
        UserDefaults.standard.removeObject(forKey: "ppass_log_entries")
        logStore = LogStore()
    }
    
    override func tearDown() {
        logStore.clear()
        logStore = nil
        UserDefaults.standard.removeObject(forKey: "ppass_log_entries")
        super.tearDown()
    }
    
    func testAdd_withQRContent_storesEntry() {
        // #given
        let content = "test-qr-content"
        
        // #when
        logStore.add(qrContent: content)
        
        // #then
        XCTAssertEqual(logStore.entries.count, 1)
        XCTAssertEqual(logStore.entries.first?.qrContent, content)
    }
    
    func testAdd_multipleEntries_maintainsOrder() {
        // #given
        let contents = ["first", "second", "third"]
        
        // #when
        contents.forEach { logStore.add(qrContent: $0) }
        
        // #then
        XCTAssertEqual(logStore.entries.count, 3)
        XCTAssertEqual(logStore.entries[0].qrContent, "third")  // Most recent first
        XCTAssertEqual(logStore.entries[1].qrContent, "second")
        XCTAssertEqual(logStore.entries[2].qrContent, "first")
    }
    
    func testClear_removesAllEntries() {
        // #given
        logStore.add(qrContent: "test1")
        logStore.add(qrContent: "test2")
        XCTAssertEqual(logStore.entries.count, 2)
        
        // #when
        logStore.clear()
        
        // #then
        XCTAssertEqual(logStore.entries.count, 0)
    }
    
    func testPersistence_loadsEntriesAfterReinitialization() {
        // #given
        let content = "persistent-content"
        logStore.add(qrContent: content)
        
        // #when
        let newLogStore = LogStore()
        
        // #then
        XCTAssertEqual(newLogStore.entries.count, 1)
        XCTAssertEqual(newLogStore.entries.first?.qrContent, content)
    }
    
    func testLogEntry_formattedOutput_containsDateAndContent() {
        // #given
        let content = "formatted-test"
        logStore.add(qrContent: content)
        
        // #when
        let formatted = logStore.entries.first?.formatted ?? ""
        
        // #then
        XCTAssertTrue(formatted.contains(content))
        XCTAssertTrue(formatted.contains(":")) // Date separator
    }
}
