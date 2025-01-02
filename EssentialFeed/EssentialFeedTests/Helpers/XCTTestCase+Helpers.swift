//
//  XCTTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2024-12-23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance, "Instance should have been deallocated. pottential memory leak",
                file: #filePath,
                line: #line
            )
        }
    }

    static let emptyData = Data()
    static let mockURL = URL(string: "https://example.com")!
    static let anyData = Data("Any data".utf8)
    static let anyError = NSError(domain: "any error", code: 1)
    static let anyHTTPURLResponse = HTTPURLResponse(
        url: mockURL, statusCode: .zero,
        httpVersion: nil, headerFields: [:]
    )

    static let nonHTTPURLResponse = URLResponse(
        url: mockURL, mimeType: nil,
        expectedContentLength: .zero, textEncodingName: nil
    )

}
