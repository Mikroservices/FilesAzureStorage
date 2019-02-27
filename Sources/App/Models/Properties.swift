import Vapor

public final class Properties {
    var contentLength: Int
    var contentMD5: String

    init(contentLength: Int, contentMD5: String) {
        self.contentLength = contentLength
        self.contentMD5 = contentMD5
    }

    enum CodingKeys: String, CodingKey {
        case contentLength = "content-Length"
        case contentMD5 = "content-MD5"
    }
}

extension Properties: Content { }
