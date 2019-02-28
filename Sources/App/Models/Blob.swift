import Vapor

public final class Blob {
    var name: String
    var properties: Properties
    var metadata: Metadata?

    init(name: String, properties: Properties, metadata: Metadata?) {
        self.name = name
        self.properties = properties
        self.metadata = metadata
    }

    enum CodingKeys: String, CodingKey {
        case name
        case properties
        case metadata
    }
}

extension Blob: Content { }
