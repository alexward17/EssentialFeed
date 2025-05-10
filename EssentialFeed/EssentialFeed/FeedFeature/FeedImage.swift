import Foundation

public struct FeedImage: Equatable, Hashable {
	public let id: UUID
	public let description: String?
	public let location: String?
	public let url: URL

    public init(id: UUID, description: String? = nil, location: String? = nil, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }

    public init(remoteItem: RemoteFeedItem) {
        self.id = remoteItem.id
        self.description = remoteItem.description
        self.location = remoteItem.location
        self.url = remoteItem.image
    }
}
