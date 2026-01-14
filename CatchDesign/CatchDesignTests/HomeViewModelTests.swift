@testable import CatchDesign
import SwiftUI
import Testing
import Foundation

class HomeViewModelTests {
    
    var displayErrorValue = false

    @Test @MainActor
    func testLoadArticlesSuccessfully() async {
        /// Given...
        let articles: [Article] = [
            .init(id: 1, title: "First", subtitle: "Subtitle", content: "Something content"),
            .init(id: 2, title: "Second", subtitle: "Subtitle", content: "Something content"),
            .init(id: 3, title: "Third", subtitle: "Subtitle", content: "Something content")
        ]
        let repository = MockHomeRepository()
        let viewModel = HomeViewModel(repository: repository)

        let displayErrorBinding = Binding {
            self.displayErrorValue
        } set: {
            self.displayErrorValue = $0
        }

        repository.expectedResult = .success(articles)
        
        /// When...
        await viewModel.loadArticles(displayErrorBinding)
        
        /// Then...
        #expect(viewModel.articles.count == 3)
        #expect(viewModel.articles[0] == articles[0])
        #expect(viewModel.articles[1] == articles[1])
        #expect(viewModel.articles[2] == articles[2])
        #expect(displayErrorValue == false)
    }
    
    @Test @MainActor
    func testLoadArticlesFailed() async {
        /// Given...
        let repository = MockHomeRepository()
        let viewModel = HomeViewModel(repository: repository)
        repository.expectedResult = .failure(.serverError)
        
        let displayErrorBinding = Binding {
            self.displayErrorValue
        } set: {
            self.displayErrorValue = $0
        }
        
        /// When...
        await viewModel.loadArticles(displayErrorBinding)
        
        /// Then...
        #expect(displayErrorValue == true)
    }
}
