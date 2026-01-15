import SwiftUI
import Observation

protocol HomeViewModel: Observable {
    var articles: [Article] { get }
    func loadArticles(_ displayError: Binding<Bool>) async
    func constructDetailsView(article: Article) -> DetailsView
}

@Observable
final class ConcreteHomeViewModel: HomeViewModel {
    private var repository: HomeRepository
    var articles = [Article]()
    
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
    
    func constructDetailsView(article: Article) -> DetailsView {
        let viewModel = DetailsViewModel(article: article)
        let detailsView = DetailsView(viewModel: viewModel)
        return detailsView
    }
}
