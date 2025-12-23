import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @StateObject private var viewModel = WatchViewModel()
    
    var body: some View {
        if let passData = viewModel.currentPass {
            WatchCardView(
                qrImage: viewModel.qrImage,
                content: passData.content
            )
        } else {
            VStack {
                Image(systemName: "qrcode")
                    .font(.title)
                Text("No QR Code")
                    .font(.caption)
                Text("Scan from iPhone")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

@MainActor
final class WatchViewModel: NSObject, ObservableObject {
    @Published var currentPass: PassData?
    @Published var qrImage: Image?
    
    private var session: WCSession?
    private let generator = QRGenerator()
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    private func updateQRImage() {
        guard let content = currentPass?.content,
              let uiImage = generator.generate(from: content) else {
            qrImage = nil
            return
        }
        qrImage = Image(uiImage: uiImage)
    }
}

extension WatchViewModel: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    nonisolated func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        guard let passData = try? JSONDecoder().decode(PassData.self, from: messageData) else { return }
        
        Task { @MainActor in
            self.currentPass = passData
            self.updateQRImage()
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let data = applicationContext["passData"] as? Data,
              let passData = try? JSONDecoder().decode(PassData.self, from: data) else { return }
        
        Task { @MainActor in
            self.currentPass = passData
            self.updateQRImage()
        }
    }
}

#Preview {
    ContentView()
}
