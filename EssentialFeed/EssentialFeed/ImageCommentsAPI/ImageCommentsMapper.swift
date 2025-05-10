import Foundation

public final class ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteImageCommentItem]
    }

    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        print("debug: isOK = \(isOK(response))")
        guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }

        return root.items.map({ .init(remoteComment: $0) })
    }

    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }

}

public struct RemoteImageCommentItem: Codable {
    let id: UUID
    let message: String
    let created_at: Date
    let author: Author

    public struct Author: Codable {
        public let username: String
    }

    public init(id: UUID, message: String, created_at: Date, author: Author) {
        self.id = id
        self.message = message
        self.created_at = created_at
        self.author = author
    }
}
