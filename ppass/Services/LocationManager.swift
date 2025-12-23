import CoreLocation
import UserNotifications

/// Manages location monitoring and local notifications
final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentPassContent: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Request location and notification permissions
    func requestPermissions() {
        locationManager.requestWhenInUseAuthorization()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    /// Start monitoring a region for location-based notifications
    func startMonitoring(location: NotificationLocation, passContent: String) {
        currentPassContent = passContent
        
        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
            radius: location.radius,
            identifier: location.identifier
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        locationManager.startMonitoring(for: region)
    }
    
    /// Stop all region monitoring
    func stopMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    /// Send local notification
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "ppass"
        content.body = "Tap to view your QR code"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Immediate
        )
        
        notificationCenter.add(request)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        sendNotification()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}
