//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2024-12-21.


// IF YOU HAVE TO DEBUG TO FIND THE SOURCE OF A FAILING TEST, YOU ARE DIMINISHING THE VALUE OF YOUR TEST
import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }

    func test_getfromURL_performsGetRequestWithURL() {
        let url = Self.mockURL
        let exp = expectation(description: "completion")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url, completion: {_ in})
        wait(for: [exp], timeout: 1)
    }

    func test_getfromURL_failsOnRequestError() {
        let error = Self.anyError
        let receivedError = resultErrorFor(data: nil, response: nil, error: error)

        XCTAssertEqual((receivedError! as NSError).domain, error.domain)
    }

    func test_getfromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: Self.nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: Self.anyData, response: nil, error: Self.anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: Self.nonHTTPURLResponse, error: Self.anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: Self.anyHTTPURLResponse, error: Self.anyError))
        XCTAssertNotNil(resultErrorFor(data: Self.anyData, response: Self.nonHTTPURLResponse, error: Self.anyError))
        XCTAssertNotNil(resultErrorFor(data: Self.anyData, response: Self.anyHTTPURLResponse, error: Self.anyError))
        XCTAssertNotNil(resultErrorFor(data: Self.anyData, response: Self.nonHTTPURLResponse, error: nil))
    }

    func test_getfromURL_succeedsOnHTTPURLResponseWithData() {
        // Given
        let data = Self.anyData
        let response = Self.anyHTTPURLResponse

        // When
        let receivedValues = resultValuesFor(data: data, response: response)

        // Assertions
        XCTAssertEqual(receivedValues?.data,  Self.anyData)
        XCTAssertEqual(receivedValues?.response.url, Self.anyHTTPURLResponse?.url)
        XCTAssertEqual(receivedValues?.response.statusCode, Self.anyHTTPURLResponse?.statusCode)
    }

    func test_getfromURL_succeedsWithEmptyOnHTTPURLResponseWithNilData() {
        // Given
        let response = Self.anyHTTPURLResponse

        // When
        let receivedValues = resultValuesFor(data: nil, response: Self.anyHTTPURLResponse)

        // Assertions
        XCTAssertEqual(receivedValues?.data, Self.emptyData)
        XCTAssertEqual(receivedValues?.response.url, response?.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response?.statusCode)
    }

    // MARK: - helpers

    private func resultValuesFor(
        data: Data?, response: HTTPURLResponse?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: nil, file: file, line: line)
        switch result {
        case let .success(receivedData, receivedResponse):
            return (receivedData, receivedResponse)
        default:
            XCTFail("Should have succeeded", file: file, line: line)
            return nil
        }
    }

    private func resultErrorFor(
        data: Data?, response: URLResponse?, error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case .success:
            XCTFail("Should fail", file: file, line: line)
            return nil
        case let .failure(error):
            return error
        }
    }

    private func resultFor(
        data: Data?, response: URLResponse?, error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)

        let exp = expectation(description: "completion")

        var receivedResult: HTTPClientResult!
        makeSUT().get(from: Self.mockURL, completion: { result in
            receivedResult = result
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1)

        return receivedResult
    }

    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private class URLProtocolStub: URLProtocol {

        // MARK: - Types

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        // MARK: - Properties

        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            Self.stub = Stub(data: data, response: response, error: error)
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(Self.self)
        }

        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(Self.self)
            stub = nil
            requestObserver = nil
        }

        // MARK: - Overrides

        override class func canInit(with request: URLRequest) -> Bool {
            true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }

        override func startLoading() {
            if let requestObserver = Self.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }

            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}

