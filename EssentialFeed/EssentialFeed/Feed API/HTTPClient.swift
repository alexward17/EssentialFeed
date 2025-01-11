// End to end test -> actually hitting the network and asserting based on expected behaviour
import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public enum HTTPStatusCode: Int {
    case OK_200 = 200

    func callAsFunction() -> Int {
        rawValue
    }
}

public protocol HTTPClient {
    /// The completion handler can be invoked on any thread.
    /// Clients are responsible for dispatching to appropriate threads if needed.
    func get(
        from url: URL,
        completion: @escaping (HTTPClientResult) -> Void
    )

}
