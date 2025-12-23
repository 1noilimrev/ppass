import SwiftUI

/// Watch-optimized QR code card view
struct WatchCardView: View {
    let qrImage: Image?
    let content: String
    
    var body: some View {
        VStack(spacing: 8) {
            if let image = qrImage {
                image
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .background(Color.white)
                    .cornerRadius(4)
            } else {
                Image(systemName: "qrcode")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
            
            Text(content)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(8)
    }
}

#Preview {
    WatchCardView(
        qrImage: nil,
        content: "https://example.com"
    )
}
