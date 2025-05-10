//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedItemsMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(
                    json, from: HTTPURLResponse(statusCode: code)
                )
            )
        }
    }

    func test_map_throwssErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)

        XCTAssertThrowsError(
            try FeedItemsMapper.map(
                invalidJSON, from: HTTPURLResponse(statusCode: 200)
            )
        )
    }

    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let emptyListJSON = makeItemsJSON([])
        XCTAssertEqual(try FeedItemsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200)), [])
    }

    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() {
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)

        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)

        let items = [item1.model, item2.model]
        let json = makeItemsJSON([item1.json, item2.json])
        XCTAssertEqual(try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: 200)), items)
    }

    // MARK: - Helpers

    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)

        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }

        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }

}

private extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: XCTestCase.anyURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
