import Foundation
import UIKit
import Swinject

class AppDelegate: NSObject, UIApplicationDelegate {
    let container = Container()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerComponents()
        return true
    }
    
    private func registerComponents() {
        container.register(NetworkClient.self) { _ in
            ConcreteNetworkClient(urlSession: URLSession.shared)
        }
        container.register(HomeRepository.self) { resolver in
            ConcreteHomeRepository(networkClient: resolver.resolve(NetworkClient.self)!)
        }
        container.register(HomeViewModel.self) { resolver in
            ConcreteHomeViewModel(repository: resolver.resolve(HomeRepository.self)!)
        }
        container.register(HomeView.self) { resolver in
            HomeView(viewModel: resolver.resolve(HomeViewModel.self)!)
        }
    }
}
