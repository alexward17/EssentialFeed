import Foundation

extension FeedImageViewModel {
    static var prototypeFeed: [FeedImageViewModel] {
        [
            FeedImageViewModel(
                description: "Short description",
                location: "Very long location that should truncate nicely and wrap at the end with an ellipsis or something",
                imageName: "autumn-trees-on-abstract-background_f1M6gsDO_thumb"
            ),
            FeedImageViewModel(
                description: "Long description that will span multiple lines and I want to see how it looks with truncation and wrapping and a lot of other words that will make it longer and longer and longer and improve my typing skills so I can write more code faster with the end result being a much better product that users will love and share and rave about",
                location: "Short location",
                imageName: "decorative-element-border-abstract-invitation-card-template-wave-design-for_z1eaJ69O_thumb"
            ),
            FeedImageViewModel(
                description: "Long description that will span multiple lines and I want to see how it looks with truncation and wrapping and a lot of other words that will make it longer and longer and longer and improve my typing skills so I can write more code faster with the end result being a much better product that users will love and share and rave about",
                location: "Very long location that should truncate nicely and wrap at the end with an ellipsis or something",
                imageName: "raking dad"
            ),
            FeedImageViewModel(
                description: nil,
                location: "Very long location that should truncate nicely and wrap at the end with an ellipsis or something",
                imageName: "sydney-vector-doodle_MkVJGFUd_thumb"
            ),
            FeedImageViewModel(
                description: nil,
                location: nil,
                imageName: "watercolor-hand-painted-corners-design-watercolor-composition-for-scrapbook_MJJpla9__thumb"
            )
        ]
    }
}
