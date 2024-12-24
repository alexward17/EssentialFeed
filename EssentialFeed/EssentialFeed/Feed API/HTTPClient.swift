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
    func get(
        from url: URL,
        completion: @escaping (HTTPClientResult) -> Void
    )

}
