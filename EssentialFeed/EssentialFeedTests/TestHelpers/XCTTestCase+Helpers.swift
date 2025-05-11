import XCTest

public extension XCTestCase {
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

    static var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }

    static var anyURL: URL {
        URL(string: "http://any-url.com")!
    }

    static var anyData: Data {
        Data("any data".utf8)
    }
    static let emptyData = Data()
    static let mockURL = URL(string: "https://example.com")!
   // static let anyData = Data("Any data".utf8)
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

public extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }

    func adding(minutes: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
