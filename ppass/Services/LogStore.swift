import Foundation

/// Simple log storage using UserDefaults
/// Stores QR scan history as "date: qr_content"
final class LogStore: ObservableObject {
    private let key = "ppass_log_entries"
    private let defaults = UserDefaults.standard
    
    @Published var entries: [LogEntry] = []
    
    init() {
        load()
    }
    
    /// Add a new log entry
    func add(qrContent: String) {
        let entry = LogEntry(date: Date(), qrContent: qrContent)
        entries.insert(entry, at: 0)
        save()
    }
    
    /// Clear all logs
    func clear() {
        entries.removeAll()
        save()
    }
    
    /// Load entries from UserDefaults
    private func load() {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([LogEntry].self, from: data) else {
            entries = []
            return
        }
        entries = decoded
    }
    
    /// Save entries to UserDefaults
    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: key)
    }
}
