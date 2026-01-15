import Foundation

protocol HomeRepository {
    func fetchArticles() async throws -> [Article]
}

final class ConcreteHomeRepository: HomeRepository {
    
    var networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchArticles() async throws -> [Article] {
        try await networkClient.get("/catchnz/ios-test/master/data/data.json")
    }
}
