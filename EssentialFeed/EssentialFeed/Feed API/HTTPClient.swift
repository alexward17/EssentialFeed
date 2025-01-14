// End to end test -> actually hitting the network and asserting based on expected behaviour
import Foundation

public enum HTTPStatusCode: Int {
    case OK_200 = 200

    func callAsFunction() -> Int {
        rawValue
    }
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    /// The completion handler can be invoked on any thread.
    /// Clients are responsible for dispatching to appropriate threads if needed.
    func get(
        from url: URL,
        completion: @escaping (Result) -> Void
    )

}
