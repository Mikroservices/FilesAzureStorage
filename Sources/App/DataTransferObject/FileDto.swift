import Vapor

final class FileDto {

    var name: String

    init(name: String) {
        self.name = name
    }
}

extension FileDto: Content { }
