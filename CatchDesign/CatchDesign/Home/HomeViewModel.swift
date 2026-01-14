import Combine

class HomeViewModel: ObservableObject {
    private var repository: HomeRepository = ConcreteHomeRepository()
    @Published var articles = [Article]()
    
    func loadArticles() {
        Task {
            do {
                articles = try await self.repository.fetchArticles()
            } catch {
                /// Typically, errors are logged here iin a service like New Relic, Firebase, or Sumologic.
                /// I chose not to implement that for simplicity.
                print("Error fetching articles: \(error)")
            }
        }
    }
}
