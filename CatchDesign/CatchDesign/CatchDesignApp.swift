import SwiftUI
import Swinject

@main
struct CatchDesignApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            appDelegate.container.resolve(HomeView.self)
        }
    }
}
