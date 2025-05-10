import Foundation

public struct ImageComment: Equatable {
    public let id: UUID
    public let massage: String
    public let createdAt: Date
    public let username: String

    public init(id: UUID, massage: String, createdAt: Date, username: String) {
        self.id = id
        self.massage = massage
        self.createdAt = createdAt
        self.username = username
    }

    public init(remoteComment: RemoteImageCommentItem) {
        self.id = remoteComment.id
        self.massage = remoteComment.message
        self.createdAt = remoteComment.created_at
        self.username = remoteComment.author.username
    }

}
