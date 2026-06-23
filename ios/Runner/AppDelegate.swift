import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API Key Setup. Replace "YOUR_API_KEY_HERE" with your real Google Maps API key.
    GMSServices.provideAPIKey("AIzaSyA5YPseoayd8QG1jTnoY1975aPxkrmaFBw")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
