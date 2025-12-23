import Foundation

/// QR code payload data shared between iOS and watchOS
struct PassData: Codable, Equatable {
    let id: UUID
    let content: String
    let createdAt: Date
    
    init(content: String) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
    }
}

/// Log entry for storing QR scan history
struct LogEntry: Codable, Equatable {
    let date: Date
    let qrContent: String
    
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return "\(formatter.string(from: date)): \(qrContent)"
    }
}

/// Location configuration for notifications
struct NotificationLocation {
    let latitude: Double
    let longitude: Double
    let radius: Double // in meters
    let identifier: String
    
    // Default: Seoul City Hall (test location)
    static let `default` = NotificationLocation(
        latitude: 37.5665,
        longitude: 126.9780,
        radius: 100,
        identifier: "ppass-default-location"
    )
}
