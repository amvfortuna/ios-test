import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    private var repository: HomeRepository
    @Published var articles = [Article]()
    
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
    func loadArticles(_ displayError: Binding<Bool>) async {
        do {
            articles = try await self.repository.fetchArticles()
            displayError.wrappedValue = false
        } catch {
            /// Typically, errors are logged here in a service like New Relic, Firebase, or Sumologic.
            /// I chose not to implement that for simplicity.
            print("Error fetching articles: \(error)")
            displayError.wrappedValue = true
        }
    }
}
