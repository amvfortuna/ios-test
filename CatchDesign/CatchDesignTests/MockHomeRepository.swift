@testable import CatchDesign
import Foundation

enum TestError: Error {
    case expectedResultNotGiven
}

class MockHomeRepository: HomeRepository {
    
    enum ExpectedResult {
        case success(_ articles: [Article])
        case failure(NetworkError)
    }
    
    var expectedResult: ExpectedResult?
    
    func fetchArticles() async throws -> [CatchDesign.Article] {
        switch expectedResult {
        case .success(let articles):
            return articles
        case .failure(let networkError):
            throw networkError
        case nil:
            throw TestError.expectedResultNotGiven
        }
    }
}
