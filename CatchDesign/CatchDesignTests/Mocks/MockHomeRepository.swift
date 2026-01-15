@testable import CatchDesign
import Foundation

/// Generic error for testing purposes
struct TestError: Error {}

class MockHomeRepository: HomeRepository {
    
    var expectedResult: Result<[Article], Error> = .success([])
    
    func fetchArticles() async throws -> [CatchDesign.Article] {
        switch expectedResult {
        case .success(let articles):
            return articles
        case .failure(let error):
            throw error
        }
    }
}
