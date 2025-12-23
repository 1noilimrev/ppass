# ppass

A minimal iOS app that scans QR codes from images and displays them in a Wallet-like card, with Apple Watch support and location-based notifications.

## Features

- **iOS App**:
  - Scan QR codes from Photos or Clipboard
  - Display QR code in a Wallet-style card
  - Location-based local notifications (default: Seoul City Hall)
  - Scan history log
- **watchOS App**:
  - Syncs the scanned QR code from iPhone
  - Displays the QR code for easy access

## Requirements

- iOS 17.0+
- watchOS 10.0+
- Xcode 15.0+

## Getting Started

1. Clone the repository
2. Open `ppass.xcodeproj`
3. Select your development team in signing settings
4. Run on your device

## Architecture

- **Shared**: Common models and CoreImage QR generator
- **ppass**: iOS target using PhotosUI and Vision framework
- **ppassWatch**: watchOS target using WatchConnectivity
- **ppassTests**: Unit tests for QR detection and generation

## Privacy

- Photos access is requested only to pick images for scanning.
- Location access is requested for local proximity notifications.
- No data is sent to external servers (except Apple Watch sync).

## License

MIT
