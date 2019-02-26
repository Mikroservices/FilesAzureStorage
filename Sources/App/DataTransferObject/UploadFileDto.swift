import Vapor

final class UploadFileDto {
    var file: File

    init(file: File) {
        self.file = file
    }
}

extension UploadFileDto: Content { }
