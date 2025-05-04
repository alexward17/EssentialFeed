import Foundation

public enum FeedCachePolicy {

    // MARK: - Constants

   public static let MAX_FEED_CACHE_AGE_IN_DAYS: Int = 7

    // MARK: - Properties

    static let calendar = Calendar(identifier: .gregorian)

    // MARK: - Helpers

    internal static func validate(_ timestamp: Date, againts date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: MAX_FEED_CACHE_AGE_IN_DAYS, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }

}
