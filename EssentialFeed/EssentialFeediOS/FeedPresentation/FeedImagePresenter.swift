import Foundation
import EssentialFeed

public final class FeedImagePresenter {

    public static func map (_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location
        )
    }

}
