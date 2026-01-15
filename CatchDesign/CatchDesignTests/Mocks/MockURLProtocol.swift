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

