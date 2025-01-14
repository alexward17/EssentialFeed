// AAA Arrange Act Assert (Given, When, Then)
// test naming convention test_testedMethod_expectedBehaviour

import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {

    // MARK: - Test Functions

    func test_load_requestsDataFromURL() {
        let url = Self.mockURL
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = Self.mockURL
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError) })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, errorCode in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJson([])
                client.complete(withStatusCode: errorCode, data: json, at: index) })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid_json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON) })
    }

    func test_load_deliversNoItemsOn200withEmptyJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            client.complete(withStatusCode: 200, data: makeItemsJson([])) })
    }

    func test_load_deliversItemsOn200withJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(
                id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://example.com/image1")!
            )

        let item2 = makeItem(
                id: UUID(), description: "Item 2", location: "here", imageURL: URL(string: "https://example.com/image1")!
            )

        let item3 = makeItem(
                id: UUID(), description: "Item 3", location: "there", imageURL: URL(string: "https://example.com/image1")!
            )

        let items = [item1.model, item2.model, item3.model]

        let itemsJSONData = makeItemsJson([item1.json, item2.json, item3.json] )

        expect(sut, toCompleteWith: .success(items), when: {
                client.complete(withStatusCode: 200, data: itemsJSONData) })
    }

    func test_load_doesNotDeliverResultAfterSutInstanceHasBeenDeallocated() {
        let url = Self.mockURL
        let client = HTTPCLientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

        var capturedResults: [RemoteFeedLoader.Result] = []
        sut?.load(completion: { capturedResults.append($0) })

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJson([]))

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - helper Functions

    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        let JSON = ["items": items]
        return  try! JSONSerialization.data(withJSONObject: JSON)
    }

    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
       let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let itemJSON = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.url.absoluteString
        ]
        return (item, itemJSON.compactMapValues({ $0 as Any }))
    }

    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error),
                      .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError,expectedError,
                               file: file, line: line)
            default: XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        waitForExpectations(timeout: 1)
    }

    private func makeSUT(
        url: URL = mockURL, file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader, client: HTTPCLientSpy) {
        let client = HTTPCLientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }

    private final class HTTPCLientSpy: HTTPClient {

        // MARK: - Properties

        private var messages = [
            (url: URL, completion: (HTTPClient.Result) -> Void)
        ]()

        var requestedURLs: [URL] {
            messages.map({ $0.url })
        }

        // MARK: - Helper Functions

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = .zero) {
            messages[index].completion(.failure(error))
        }

        func complete(
            withStatusCode code: Int,
            data: Data,
            at index: Int = .zero
        ) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }

}
