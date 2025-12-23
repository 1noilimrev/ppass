import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var logStore = LogStore()
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var qrContent: String?
    @State private var qrImage: UIImage?
    @State private var errorMessage: String?
    @State private var isProcessing = false
    @State private var showLogs = false
    
    private let detector = QRDetector()
    private let generator = QRGenerator()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let qrImage = qrImage, let content = qrContent {
                    PassCardView(qrImage: qrImage, content: content)
                } else {
                    ContentUnavailableView(
                        "No QR Code",
                        systemImage: "qrcode",
                        description: Text("Select an image or paste from clipboard")
                    )
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                HStack(spacing: 16) {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        Label("Photos", systemImage: "photo")
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        pasteFromClipboard()
                    } label: {
                        Label("Paste", systemImage: "doc.on.clipboard")
                    }
                    .buttonStyle(.bordered)
                }
                .disabled(isProcessing)
            }
            .padding()
            .navigationTitle("ppass")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showLogs = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            .sheet(isPresented: $showLogs) {
                LogListView(logStore: logStore)
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    await processSelectedItem(newItem)
                }
            }
            .onAppear {
                locationManager.requestPermissions()
            }
        }
    }
    
    private func processSelectedItem(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isProcessing = true
        errorMessage = nil
        
        defer { isProcessing = false }
        
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                errorMessage = "Failed to load image"
                return
            }
            
            await processImage(image)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func pasteFromClipboard() {
        guard let image = UIPasteboard.general.image else {
            errorMessage = "No image in clipboard"
            return
        }
        
        Task {
            await processImage(image)
        }
    }
    
    @MainActor
    private func processImage(_ image: UIImage) async {
        isProcessing = true
        errorMessage = nil
        
        defer { isProcessing = false }
        
        do {
            let result = try await detector.detect(in: image)
            qrContent = result.content
            qrImage = generator.generate(from: result.content)
            
            // Log the scan
            logStore.add(qrContent: result.content)
            
            // Send to Watch
            let passData = PassData(content: result.content)
            WatchConnector.shared.sendToWatch(passData: passData)
            
            // Start location monitoring
            locationManager.startMonitoring(
                location: .default,
                passContent: result.content
            )
        } catch {
            errorMessage = error.localizedDescription
            qrContent = nil
            qrImage = nil
        }
    }
}

struct LogListView: View {
    @ObservedObject var logStore: LogStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(logStore.entries, id: \.date) { entry in
                    Text(entry.formatted)
                        .font(.caption)
                }
            }
            .navigationTitle("Scan History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        logStore.clear()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
