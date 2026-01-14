import Foundation

/// An enum listing possible errors related to network calls for error handling.
/// Add more cases as needed.
enum NetworkError: Error {
    case serverError
    case noInternet
    case decodingError(_ error: Error)
    case otherError(_ error: Error)
}

protocol HomeRepository {
    func fetchArticles() async throws -> [Article]
}

/// A concrete implementation of the HomeRepository protocol
class ConcreteHomeRepository: HomeRepository {
    /// Network call to fetch the JSON data from the API.
    /// Returns an array of `Articles`, or throw a `NetworkError`
    func fetchArticles() async throws -> [Article] {
        do {
            let url = URL(string: "https://raw.githubusercontent.com/catchnz/ios-test/master/data/data.json")!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Any response other than 200 will be treated as a failure for simplicity.
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.serverError
            }
            
            return try JSONDecoder().decode([Article].self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.noInternet
        } catch {
            throw NetworkError.otherError(error)
        }
    }
}
