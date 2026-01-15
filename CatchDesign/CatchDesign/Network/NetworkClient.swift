import Foundation

/// An enum listing possible errors related to network calls for error handling.
/// Add more cases as needed.
enum NetworkError: Error, Equatable {
    case serverError
    case noInternet
    case decodingError(_ error: Error)
    case otherError(_ error: Error)
    
    /// Make this enum `Equatable` to make testing easier
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (let .decodingError(lhsError), let .decodingError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (let .otherError(lhsError), let .otherError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.serverError, .serverError), (.noInternet, .noInternet):
            return true
        default:
            return false
        }
    }
}

protocol NetworkClient {
    func get<T: Decodable>(_ path: String) async throws -> [T]
}

/// A simple network client to handle the API call(s).
class ConcreteNetworkClient: NetworkClient {
    let urlSession: URLSession
    let baseUrl = URL(string: "https://raw.githubusercontent.com")!
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    /// A simple GET function that fetches data from the given URL path.
    /// Returns an array of `Decodable` objects, and throws a `NetworkError` if there's an issue.
    func get<T: Decodable>(_ path: String) async throws -> [T] {
        do {
            let url = baseUrl.appending(path: path)
            let (data, response) = try await urlSession.data(from: url)
            
            // Any response other than 200 will be treated as a failure for simplicity.
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.serverError
            }
            
            return try JSONDecoder().decode([T].self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.noInternet
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.otherError(error)
        }
    }
}
