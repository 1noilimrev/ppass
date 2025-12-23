import WatchConnectivity

/// Handles communication between iOS app and Apple Watch
final class WatchConnector: NSObject, ObservableObject {
    static let shared = WatchConnector()
    
    private var session: WCSession?
    
    @Published var isReachable = false
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    /// Send QR content to Watch
    func sendToWatch(passData: PassData) {
        guard let session = session,
              session.isReachable else {
            // Try using application context for background transfer
            sendViaContext(passData: passData)
            return
        }
        
        do {
            let data = try JSONEncoder().encode(passData)
            session.sendMessageData(data, replyHandler: nil, errorHandler: { error in
                print("Watch send error: \(error)")
            })
        } catch {
            print("Encoding error: \(error)")
        }
    }
    
    /// Send via application context (persists until Watch reads it)
    private func sendViaContext(passData: PassData) {
        guard let session = session else { return }
        
        do {
            let data = try JSONEncoder().encode(passData)
            try session.updateApplicationContext(["passData": data])
        } catch {
            print("Context update error: \(error)")
        }
    }
}

extension WatchConnector: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
