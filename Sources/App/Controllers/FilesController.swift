import Vapor

/// Controls basic CRUD operations.
final class FilesController: RouteCollection {

    func boot(router: Router) throws {
        router.get("/files", use: files)
        router.post(UploadFileDto.self, at: "/files", use: create)
    }

    func files(request: Request) throws -> [FileDto] {
        return []
    }

    func create(request: Request, uploadFileDto: UploadFileDto) throws -> Future<Response> {
        let authorizationService = try request.make(AuthorizationService.self)
        guard let userNameFromToken = try authorizationService.getUserNameFromBearerToken(request: request) else {
            throw Abort(.unauthorized)
        }

        let userNameNormalized = userNameFromToken.lowercased()
        let fileToken = TokenGenerator.generate()
        let fileId = "\(fileToken).\(uploadFileDto.file.ext ?? "unknown")"
        let metadata = ["fileName": uploadFileDto.file.filename]

        return try request.content.decode(UploadFileDto.self).flatMap(to: HTTPStatus.self) { uploadFileDto in
            let azureStorageService = try request.make(AzureStorageService.self)
            return try azureStorageService.createFile(inContainer: userNameNormalized,
                                                      content: uploadFileDto.file.data,
                                                      fileName: fileId,
                                                      withMetadata: metadata,
                                                      inRequest: request)

        }.flatMap(to: Response.self) { azureStotageStatus in
            if azureStotageStatus.isSuccess() {
                return try FileDto(id: fileId, name: uploadFileDto.file.filename, size: uploadFileDto.file.data.count).encode(for: request)
            }

            throw AzureStorageError.fileNotCreated
        }.map(to: Response.self) { response in
            response.http.headers.replaceOrAdd(name: .location, value: "\(request.http.url.path)/\(fileId)")
            response.http.status = .created

            return response
        }
    }
}
