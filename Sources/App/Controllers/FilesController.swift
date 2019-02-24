import Vapor

/// Controls basic CRUD operations.
final class FilesController: RouteCollection {

    func boot(router: Router) throws {
        router.get("/files", use: files)
        router.post(FileDto.self, at: "/files", use: create)
    }

    func files(request: Request) throws -> [FileDto] {
        return [FileDto(name: "name.png"), FileDto(name: "other.jpg")]
    }

    func create(request: Request, fileDto: FileDto) throws -> Future<HTTPResponseStatus> {
        let azureStorageService = try request.make(AzureStorageService.self)

        return try azureStorageService.createContainer(withName: "testcontainersecond", inRequest: request)
    }
}
