import Vapor
import JWT

final class AzureStorageService: ServiceType {

    static func makeService(for container: Container) throws -> AzureStorageService {
        return AzureStorageService()
    }

    /// Creates file in Azure storage (as block blob).
    ///
    /// - Parameter inContainer: Container name.
    /// - Parameter content: File content.
    /// - Parameter fileName: Name of file.
    /// - Parameter contentType: File content type.
    /// - Parameter withMetadata: Additional metadata.
    /// - Parameter inRequest: Current request scope.
    /// - Returns: Response status from external provider.
    public func createFile(inContainer containerName: String,
                           content: Data,
                           fileName: String,
                           contentType: MediaType?,
                           withMetadata metadata: [String:String]? = nil,
                           inRequest request: Request) throws -> Future<HTTPResponseStatus> {

        return try self.isContainerExists(withName: containerName, inRequest: request).flatMap(to: HTTPStatus.self) { isContainerExists in

            if (!isContainerExists) {
                return try self.createContainer(withName: containerName, inRequest: request)
            }

            return Future.map(on: request) { return HTTPResponseStatus.ok }
        }.flatMap(to: HTTPResponseStatus.self) { containerResult in

            if containerResult.isSuccess() {
                return try self.createFileInternal(inContainer: containerName,
                                                   content: content,
                                                   fileName: fileName,
                                                   contentType: contentType,
                                                   withMetadata: metadata,
                                                   inRequest: request)
            }

            return Future.map(on: request) { return containerResult }
        }
    }

    /// Returns list of files from container.
    ///
    /// - Parameter fromContainer: Container name.
    /// - Parameter inRequest: Current request scope.
    /// - Returns: List of files.
    public func getFiles(fromContainer containerName: String, inRequest request: Request) throws -> Future<[FileDto]> {
        return try self.getFilesInternal(fromContainer:containerName, inRequest:request)
    }

    /// Returns list of files from container.
    ///
    /// - Parameter fromContainer: Container name.
    /// - Parameter withFileName: File name.
    /// - Parameter inRequest: Current request scope.
    /// - Returns: List of files.
    public func getFile(fromContainer containerName: String, withFileName fileName: String, inRequest request: Request) throws -> Future<FileDto?> {
        return try self.getFilesInternal(fromContainer:containerName, withPrefix: fileName, inRequest:request).map(to: FileDto?.self) { filesDto in
            return filesDto.first
        }
    }

    /// Creating new conatiner in Azure Storage.
    ///
    /// More information: https://docs.microsoft.com/en-us/rest/api/storageservices/create-container
    /// This method send the request similar to below:
    ///
    /// PUT "https://lettererdev.blob.core.windows.net/mycontainer?restype=container"
    /// Authorization: SharedKey lettererdev:Z5043vY9MesKNh0PNtksNc9nbXSSqGHueE00JdjidOQ=
    /// x-ms-version: 2011-08-18
    /// x-ms-date: Sun, 25 Sep 2011 22:50:32 GMT
    ///
    /// - Parameter withName: Container name.
    /// - Parameter inRequest: Current request scope.
    /// - Returns: Response status from external provider.
    private func createContainer(withName name: String, inRequest request: Request) throws -> Future<HTTPResponseStatus> {

        let settingsStorage = try request.make(SettingsStorage.self)
        let azureSignatureService = try request.make(AzureSignatureService.self)
        let accountName = settingsStorage.azureStorageAccountName
        let client = try request.client()

        var headers = HTTPHeaders()
        headers.add(name: .xMsVersion, value: "2011-08-18")
        headers.add(name: .xMsDate, value: Date().rfc1123US)
        headers.add(name: .xMsBlobPublicAccess, value: "blob")

        let uri = "\(name)?restype=container"
        let signature = try azureSignatureService.signature(accountName: accountName, method: .PUT, uri: uri, headers: headers)
        headers.add(name: .authorization, value: "SharedKey lettererdev:\(signature)")

        return client.put("https://\(accountName).blob.core.windows.net/\(uri)", headers: headers).map(to: HTTPStatus.self) { httpResponse in

            if !httpResponse.http.status.isSuccess() {
                let logger = try request.make(Logger.self)
                logger.error(httpResponse.debugDescription)
            }

            return httpResponse.http.status
        }
    }

    /// Checking if container exists.
    ///
    /// More information: https://docs.microsoft.com/en-us/rest/api/storageservices/get-container-properties
    /// This method send the request similar to below:
    ///
    /// GET "https://lettererdev.blob.core.windows.net/mycontainer?restype=container"
    /// Authorization: SharedKey lettererdev:Z5043vY9MesKNh0PNtksNc9nbXSSqGHueE00JdjidOQ=
    /// x-ms-version: 2011-08-18
    /// x-ms-date: Sun, 25 Sep 2011 22:50:32 GMT
    ///
    /// - Parameter withName: Container name.
    /// - Parameter inRequest: Current request scope.
    /// - Returns: True if container exists.
    private func isContainerExists(withName name: String, inRequest request: Request) throws -> Future<Bool> {

        let settingsStorage = try request.make(SettingsStorage.self)
        let azureSignatureService = try request.make(AzureSignatureService.self)
        let accountName = settingsStorage.azureStorageAccountName

        var headers = HTTPHeaders()
        headers.add(name: .xMsVersion, value: "2011-08-18")
        headers.add(name: .xMsDate, value: Date().rfc1123US)

        let uri = "\(name)?restype=container"
        let signature = try azureSignatureService.signature(accountName: accountName, method: .GET, uri: uri, headers: headers)
        headers.add(name: .authorization, value: "SharedKey lettererdev:\(signature)")

        let client = try request.client()
        return client.get("https://\(accountName).blob.core.windows.net/\(uri)" , headers: headers).map(to: Bool.self) { httpResponse in

            if !httpResponse.http.status.isSuccess() {
                let logger = try request.make(Logger.self)
                logger.error(httpResponse.debugDescription)
            }

            return httpResponse.http.status == HTTPResponseStatus.ok
        }
    }

    /// Creating new file in Azure storage.
    ///
    /// More information: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// This method send the request similar to below:
    ///
    /// PUT "https://lettererdev.blob.core.windows.net/mycontainer/myblob"
    /// Authorization: SharedKey lettererdev:YhuFJjN4fAR8/AmBrqBz7MG2uFinQ4rkh4dscbj598g=
    /// Content-Length: 11
    /// Content-Type: text/plain; charset=UTF-8
    /// x-ms-version: 2015-02-21
    /// x-ms-date: Sun, 25 Sep 2011 22:50:32 GMT
    /// x-ms-blob-type: BlockBlob
    /// x-ms-meta-key1: value1
    /// x-ms-meta-key2: value2
    ///
    /// Content
    ///
    /// - Parameter inContainer: Container name.
    /// - Parameter content: File content.
    /// - Parameter fileName: Name of file.
    /// - Parameter contentType: File content type.
    /// - Parameter withMetadata: Additional metadata.
    /// - Parameter inRequest: Current request scope.
    /// - Returns: Response status from external provider.
    private func createFileInternal(inContainer containerName: String,
                                    content: Data,
                                    fileName: String,
                                    contentType: MediaType?,
                                    withMetadata metadata: [String:String]? = nil,
                                    inRequest request: Request) throws -> Future<HTTPResponseStatus> {

        let settingsStorage = try request.make(SettingsStorage.self)
        let azureSignatureService = try request.make(AzureSignatureService.self)
        let accountName = settingsStorage.azureStorageAccountName

        var headers = HTTPHeaders()
        headers.add(name: .xMsVersion, value: "2015-02-21")
        headers.add(name: .xMsDate, value: Date().rfc1123US)
        headers.add(name: .xMsBlobType, value: "BlockBlob")
        headers.add(name: .contentLength, value: "\(content.count)")
        headers.add(name: .contentType, value: MediaType.binary.serialize())
        headers.add(name: .xMsBlobContentType, value: contentType?.serialize() ?? MediaType.binary.serialize())

        if let additionalMetaData = metadata {
            for data in additionalMetaData {
                headers.add(name: "x-ms-meta-\(data.key)", value: data.value)
            }
        }

        let uri = "\(containerName)/\(fileName)"
        let signature = try azureSignatureService.signature(accountName: accountName, method: .PUT, uri: uri, headers: headers)
        headers.add(name: .authorization, value: "SharedKey lettererdev:\(signature)")

        let client = try request.client()
        return client.put("https://\(accountName).blob.core.windows.net/\(uri)" , headers: headers) { httpRequest in
            try httpRequest.content.encode(content, as: .binary)
        }.map(to: HTTPResponseStatus.self) { httpResponse in

            if !httpResponse.http.status.isSuccess() {
                let logger = try request.make(Logger.self)
                logger.error(httpResponse.debugDescription)
            }

            return httpResponse.http.status
        }
    }

    /// Returns list of files from container.
    ///
    /// More information: https://docs.microsoft.com/en-us/rest/api/storageservices/list-blobs
    /// This method send the request similar to below:
    ///
    /// GET "https://myaccount.blob.core.windows.net/mycontainer?restype=container&comp=list"
    /// Authorization: SharedKey lettererdev:YhuFJjN4fAR8/AmBrqBz7MG2uFinQ4rkh4dscbj598g=
    /// x-ms-date: Sun, 25 Sep 2011 22:50:32 GMT
    /// x-ms-version: 2015-02-21
    ///
    /// - Parameter fromContainer: Container name.
    /// - Parameter inRequest: Current request scope.
    /// - Returns: List of files.
    public func getFilesInternal(fromContainer containerName: String,
                                 withPrefix prefix: String? = nil,
                                 inRequest request: Request) throws -> Future<[FileDto]> {

        let settingsStorage = try request.make(SettingsStorage.self)
        let azureSignatureService = try request.make(AzureSignatureService.self)
        let accountName = settingsStorage.azureStorageAccountName
        let client = try request.client()

        var headers = HTTPHeaders()
        headers.add(name: .xMsVersion, value: "2015-02-21")
        headers.add(name: .xMsDate, value: Date().rfc1123US)

        var uri = "\(containerName)?restype=container&comp=list&include=metadata"
        if let prefixUnboxed = prefix {
            uri = uri + "&prefix=\(prefixUnboxed)"
        }

        let signature = try azureSignatureService.signature(accountName: accountName, method: .GET, uri: uri, headers: headers)
        headers.add(name: .authorization, value: "SharedKey lettererdev:\(signature)")

        return client.get("https://\(accountName).blob.core.windows.net/\(uri)", headers: headers).flatMap(to: EnumerationResults.self) { httpResponse in

            if !httpResponse.http.status.isSuccess() {
                let logger = try request.make(Logger.self)
                logger.error(httpResponse.debugDescription)
            }

            print(httpResponse)
            return try httpResponse.content.decode(EnumerationResults.self)
        }.map(to: [FileDto].self) { enumerationResult in
            var filesDtos = [FileDto]()

            guard let blobs = enumerationResult.blobs else {
                return filesDtos
            }

            for blob in blobs.items {
                filesDtos.append(
                    FileDto(id: blob.name,
                            name: blob.metadata?.fileName ?? "",
                            size: blob.properties.contentLength,
                            contentMD5: blob.properties.contentMD5
                    )
                )
            }

            return filesDtos
        }
    }
}
