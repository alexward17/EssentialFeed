//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Alex Ward on 2024-12-23.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct UnexpercetedRepresentationValueError: Error {}

    public func get(from url: URL, completion completionHandler: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url, completionHandler: { data, response, error in
            completionHandler(Result(catching: {
                if let error { throw error }
                else if let response = response as? HTTPURLResponse, let data {
                    return (data, response)
                } else { throw UnexpercetedRepresentationValueError() }
            }))
        }).resume()
    }
}
