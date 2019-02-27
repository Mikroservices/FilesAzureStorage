import Vapor

public final class Metadata {
    var fileName: String?

    init(fileName: String?) {
        self.fileName = fileName
    }

    enum CodingKeys: String, CodingKey {
        case fileName = "fileName"
    }
}

extension Metadata: Content { }
