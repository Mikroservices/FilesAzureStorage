import Vapor

public final class Blobs {
    var items: [Blob]

    init(items: [Blob]) {
        self.items = items
    }

    enum CodingKeys: String, CodingKey {
        case items = "blob"
    }
}

extension Blobs: Content { }
