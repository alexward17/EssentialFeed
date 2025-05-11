import Foundation

public struct FeedImageViewModel {

    let description: String?
    let location: String?

    var hasLocation: Bool {
        location != nil
    }

}
