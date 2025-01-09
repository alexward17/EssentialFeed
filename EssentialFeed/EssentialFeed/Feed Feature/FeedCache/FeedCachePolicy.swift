//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Alex Ward on 2025-01-09.
//

import Foundation

internal enum FeedCachePolicy {

    // MARK: - Constants

    static let MAX_CACHE_AGE_IN_DAYS: Int = 7

    // MARK: - Properties

    static let calendar = Calendar(identifier: .gregorian)

    // MARK: - Helpers

    internal static func validate(_ timestamp: Date, againts date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: MAX_CACHE_AGE_IN_DAYS, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }

}
