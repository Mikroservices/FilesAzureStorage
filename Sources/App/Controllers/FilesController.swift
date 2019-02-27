import Vapor
import XMLCoder

/// Controls basic CRUD operations.
final class FilesController: RouteCollection {

    func boot(router: Router) throws {
        router.get("/files", use: files)
        router.get("/files", String.parameter, use: file)
        router.post(UploadFileDto.self, at: "/files", use: create)
    }

    func files(request: Request) throws -> Future<[FileDto]> {

        let authorizationService = try request.make(AuthorizationService.self)
        guard let userNameFromToken = try authorizationService.getUserNameFromBearerToken(request: request) else {
            throw Abort(.unauthorized)
        }

        let userNameNormalized = userNameFromToken.lowercased()
        let azureStorageService = try request.make(AzureStorageService.self)
        return try azureStorageService.getFiles(fromContainer: userNameNormalized, inRequest: request)
    }

    func file(request: Request) throws -> Future<Response> {

        let authorizationService = try request.make(AuthorizationService.self)
        guard let userNameFromToken = try authorizationService.getUserNameFromBearerToken(request: request) else {
            throw Abort(.unauthorized)
        }

        let fileName = try request.parameters.next(String.self)

        let userNameNormalized = userNameFromToken.lowercased()
        let azureStorageService = try request.make(AzureStorageService.self)
        return try azureStorageService.getFile(fromContainer: userNameNormalized, withFileName: fileName, inRequest: request).flatMap(to: Response.self) { fileDto in

            guard let fileDtoUnboxed = fileDto else {
                return Future.map(on: request) { return Response(http: HTTPResponse(status: .notFound), using: request) }
            }

            return try fileDtoUnboxed.encode(for: request)
        }
    }

    func create(request: Request, uploadFileDto: UploadFileDto) throws -> Future<Response> {

        let authorizationService = try request.make(AuthorizationService.self)
        guard let userNameFromToken = try authorizationService.getUserNameFromBearerToken(request: request) else {
            throw Abort(.unauthorized)
        }

        let azureStorageService = try request.make(AzureStorageService.self)
        let userNameNormalized = userNameFromToken.lowercased()
        let fileToken = TokenGenerator.generate()
        let fileId = "\(fileToken).\(uploadFileDto.file.ext ?? "unknown")"
        let metadata = ["fileName": uploadFileDto.file.filename]

        return try request.content.decode(UploadFileDto.self).flatMap(to: HTTPStatus.self) { uploadFileDto in
            return try azureStorageService.createFile(inContainer: userNameNormalized,
                                                      content: uploadFileDto.file.data,
                                                      fileName: fileId,
                                                      contentType: uploadFileDto.file.contentType,
                                                      withMetadata: metadata,
                                                      inRequest: request)

        }.flatMap(to: FileDto?.self) { azureStotageStatus in
            if azureStotageStatus.isSuccess() {
                return try azureStorageService.getFile(fromContainer: userNameNormalized, withFileName: fileId, inRequest: request)
            }

            throw AzureStorageError.fileNotCreated
        }.flatMap(to: Response.self) { fileDto in
            guard let fileDtoUnboxed = fileDto else {
                throw AzureStorageError.filePropertiesNotReaded
            }

            return try fileDtoUnboxed.encode(for: request)
        }.map(to: Response.self) { response in
            response.http.headers.replaceOrAdd(name: .location, value: "\(request.http.url.path)/\(fileId)")
            response.http.status = .created

            return response
        }
    }
}
