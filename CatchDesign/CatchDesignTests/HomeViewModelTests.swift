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
        repository.expectedResult = .failure(TestError())
        
        let displayErrorBinding = Binding {
            self.displayErrorValue
        } set: {
            self.displayErrorValue = $0
        }
        
        /// When...
        await viewModel.loadArticles(displayErrorBinding)
        
        /// Then...
        #expect(displayErrorValue == true)
        #expect(viewModel.articles.isEmpty)
    }
    
    @Test @MainActor
    func testConstructDetailsView() async {
        /// Given...
        let viewModel = HomeViewModel(repository: MockHomeRepository())
        let article = Article(
            id: 1,
            title: "Title",
            subtitle: "Subtitle",
            content: "Content"
        )
        
        /// When...
        let detailsView = viewModel.constructDetailsView(article: article)
        
        /// Then...
        #expect(detailsView.viewModel.article == article)
    }
}
