import Foundation

public struct ImageComment: Equatable {
    public let id: UUID
    public let massage: String
    public let createAt: Date
    public let username: String

    public init(id: UUID, massage: String, createAt: Date, username: String) {
        self.id = id
        self.massage = massage
        self.createAt = createAt
        self.username = username
    }

}
