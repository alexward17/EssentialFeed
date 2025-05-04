import Foundation

public struct RemoteImageCommentItem: Codable {
    public let id: UUID
    public let message: String
    public let created_at: Date
    public let author: Author

    public init(id: UUID, message: String, created_at: Date, author: Author) {
        self.id = id
        self.message = message
        self.created_at = created_at
        self.author = author
    }

}

public struct Author: Codable {
    public let username: String
}

