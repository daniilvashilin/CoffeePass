import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct CoffeePassApp: App {
    @State private var container = AppContainer()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("appearance") private var appearanceRaw: String = AppearanceOption.system.rawValue
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
                .preferredColorScheme((AppearanceOption(rawValue: appearanceRaw) ?? .system).colorScheme)
        }
    }
}
