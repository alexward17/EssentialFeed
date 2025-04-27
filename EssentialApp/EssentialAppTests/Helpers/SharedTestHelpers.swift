import Foundation
import EssentialFeed
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

    static var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }


    static var anyURL: URL {
        URL(string: "http://any-url.com")!
    }

    static var anyData: Data {
        Data("any data".utf8)
    }

    final func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
    }

}
