import Foundation

public final class ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteImageCommentItem]
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageCommentItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        print("debug: isOK = \(isOK(response))")
        guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }

        return root.items
    }

    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }

}

public extension Array where Element == RemoteImageCommentItem {
    func toModels() -> [ImageComment] {
        map { ImageComment(id: $0.id, massage: $0.message, createAt: $0.created_at, username: $0.author.username) }
    }
}
