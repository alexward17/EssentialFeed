import Foundation

public enum Endpoint {
    case getFeed

    public var path: String {
        switch self {
        case .getFeed: return "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed"
        }
    }
}
