import Vapor

final class FileDto {

    let id: String
    let name: String
    let size: Int
    let contentMD5: String

    init(id: String, name: String, size: Int, contentMD5: String) {
        self.id = id
        self.name = name
        self.size = size
        self.contentMD5 = contentMD5
    }
}

extension FileDto: Content { }
