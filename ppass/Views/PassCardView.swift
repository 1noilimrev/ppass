import SwiftUI

/// Simple card view displaying QR code
struct PassCardView: View {
    let qrImage: UIImage?
    let content: String
    
    var body: some View {
        VStack(spacing: 16) {
            if let image = qrImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            
            Text(content)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .truncationMode(.middle)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

#Preview {
    PassCardView(
        qrImage: nil,
        content: "https://example.com/test"
    )
}
