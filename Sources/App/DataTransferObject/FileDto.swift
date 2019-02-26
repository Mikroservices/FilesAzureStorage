import Vapor

final class FileDto {

    let id: String
    let name: String
    let size: Int

    init(id: String, name: String, size: Int) {
        self.id = id
        self.name = name
        self.size = size
    }
}

extension FileDto: Content { }
