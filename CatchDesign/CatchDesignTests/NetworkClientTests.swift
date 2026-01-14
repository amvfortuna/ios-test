@testable import CatchDesign
import Foundation
import Testing

class MockURLProtocol: URLProtocol {
    
    struct MockResponse {
        let statusCode: Int
        let data: Data
        let error: Error?
    }
    
    static let queue = DispatchQueue(label: "MockURLProtocolQueue")
    static var responses = [URL: MockResponse]()
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    static func register(_ response: MockResponse, for urlPath: String) {
        let baseUrl = URL(string: "https://raw.githubusercontent.com")!
        let url = baseUrl.appending(path: urlPath)
        queue.sync {
            responses[url] = response
        }
    }
    
    override func startLoading() {
        guard let client, let requestUrl = request.url, let mockResponse = MockURLProtocol.responses[requestUrl] else {
            Issue.record("Request client, URL, or mocked response is not available.")
            return
        }
        
        /// If an error is provided, manually fail the request
        guard mockResponse.error == nil else {
            client.urlProtocol(self, didFailWithError: mockResponse.error!)
            return
        }
        
        guard let urlResponse = HTTPURLResponse(
                url: requestUrl,
                statusCode: mockResponse.statusCode,
                httpVersion: nil,
                headerFields: nil
              ) else {
            Issue.record("Attempted to create a URLResponse with invalid parameters.")
            return
        }
        
        /// Manually receive the mock response
        client.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
        /// Manually load the data
        client.urlProtocol(self, didLoad: mockResponse.data)
        /// Manually tells the client that loading is done
        client.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

class NetworkClientTests {
    
    @Test @MainActor
    func testGETRequestSuccessfully() async throws {
        /// Given...
        let networkClient = makeClient()
        let mockData = """
        [
            {"id": 7, "title": "Title 1", "subtitle": "Subtitle", "content": "Some content"},
            {"id": 8, "title": "Title 2", "subtitle": "Subtitle", "content": "Some content"},
            {"id": 9, "title": "Title 3", "subtitle": "Subtitle", "content": "Some content"}
        ]    
        """.data(using: .utf8)!
        let urlPath = "success-api"
        
        MockURLProtocol.register(MockURLProtocol.MockResponse(statusCode: 200, data: mockData, error: nil), for: urlPath)
        
        /// When...
        let results: [Article] = try await networkClient.get(urlPath)
        
        /// Then...
        #expect(results.count == 3)
        #expect(results[0].id == 7)
        #expect(results[1].id == 8)
        #expect(results[2].id == 9)
    }
    
    @Test @MainActor
    func testGETRequestFailed_ServerError() async throws {
        /// Given...
        let networkClient = makeClient()
        let urlPath = "server-error-api"
        
        MockURLProtocol.register(MockURLProtocol.MockResponse(statusCode: 400, data: Data(), error: nil), for: urlPath)
        
        /// When... & Then...
        await #expect(throws: NetworkError.serverError) {
            _ = try await networkClient.get(urlPath) as [Article]
        }
    }
    
    @Test @MainActor
    func testGETRequestFailed_DecodingError() async throws {
        /// Given...
        let networkClient = makeClient()
        let mockIncorrectData = """
        [
            {"id": 7, "title": "Title 1", "subtitle": "Subtitle", "incorrect-key": "Some content"}
        ]    
        """.data(using: .utf8)!
        let urlPath = "decoding-error-api"
        
        MockURLProtocol.register(MockURLProtocol.MockResponse(statusCode: 200, data: mockIncorrectData, error: nil), for: urlPath)
                
        /// When...
        let error = await #expect(throws: NetworkError.self) {
            _ = try await networkClient.get(urlPath) as [Article]
        }
        
        /// Then...
        guard let error, case .decodingError = error else {
            Issue.record("The error returned must be a NetworkError.decodingError(_)")
            return
        }
    }
    
    @Test @MainActor
    func testGETRequestFailed_NoInternetError() async throws {
        /// Given...
        let networkClient = makeClient()
        let urlPath = "no-internet-api"
        
        MockURLProtocol.register(MockURLProtocol.MockResponse(statusCode: 0, data: Data(), error: URLError(.notConnectedToInternet)), for: urlPath)
                
        /// When... & Then...
        await #expect(throws: NetworkError.noInternet.self) {
            _ = try await networkClient.get(urlPath) as [Article]
        }
    }
    
    @Test @MainActor
    func testGETRequestFailed_OtherError() async throws {
        /// Given...
        let networkClient = makeClient()
        let urlPath = "other-error-api"
        
        MockURLProtocol.register(MockURLProtocol.MockResponse(statusCode: 0, data: Data(), error: TestError()), for: urlPath)
                
        /// When...
        let error = await #expect(throws: NetworkError.self) {
            _ = try await networkClient.get(urlPath) as [Article]
        }
        
        /// Then...
        guard let error, case .otherError = error else {
            Issue.record("The error returned must be a NetworkError.otherError(_)")
            return
        }
    }
    
    @MainActor
    func makeClient() -> NetworkClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        
        return ConcreteNetworkClient(urlSession: urlSession)
    }
}
