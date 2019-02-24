import Vapor
import JWT

final class AzureStorageService: ServiceType {

    static func makeService(for container: Container) throws -> AzureStorageService {
        return AzureStorageService()
    }

    /// Creating new conatiner in Azure Storage.
    ///
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
    public func createContainer(withName name: String, inRequest request: Request) throws -> Future<HTTPResponseStatus> {

        let settingsStorage = try request.make(SettingsStorage.self)
        let azureSignatureService = try request.make(AzureSignatureService.self)
        let accountName = settingsStorage.azureStorageAccountName

        var headers = HTTPHeaders()
        headers.add(name: .xMsVersion, value: "2011-08-18")
        headers.add(name: .xMsDate, value: Date().rfc1123US)

        let uri = "\(name)?restype=container"
        let signature = try azureSignatureService.signature(accountName: accountName, method: .PUT, uri: uri, headers: headers)
        headers.add(name: .authorization, value: "SharedKey lettererdev:\(signature)")

        let client = try request.client()
        return client.put("https://\(accountName).blob.core.windows.net/\(uri)", headers: headers)
        .map(to: HTTPResponseStatus.self) { httpResponse in
            print(httpResponse.content)
            return httpResponse.http.status
        }
    }

    /// Checking if container exists.
    ///
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
    public func isContainerExists(withName name: String, inRequest request: Request) throws -> Future<Bool> {

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
        return client.get("https://\(accountName).blob.core.windows.net/\(uri)" , headers: headers)
            .map(to: Bool.self) { httpResponse in
                print(httpResponse.content)
                return httpResponse.http.status == HTTPResponseStatus.ok
        }
    }

    // PUT "https://lettererdev.blob.core.windows.net/mycontainer/myblob"
    // Authorization: SharedKey lettererdev:YhuFJjN4fAR8/AmBrqBz7MG2uFinQ4rkh4dscbj598g=
    // Content-Length: 11
    // Content-Type: text/plain; charset=UTF-8
    // x-ms-version: 2015-02-21
    // x-ms-date: Sun, 25 Sep 2011 22:50:32 GMT
    // x-ms-blob-type: BlockBlob
    // x-ms-meta-key1: value1
    // x-ms-meta-key2: value2
    public func createFile(inContainer containerName: String, withName name: String, content: Data) {

    }

    public func getFiles(fromContainer containerName: String) -> [String] {
        // GET "https://myaccount.blob.core.windows.net/mycontainer?restype=container&comp=list"
        // Authorization: SharedKey lettererdev:YhuFJjN4fAR8/AmBrqBz7MG2uFinQ4rkh4dscbj598g=
        // x-ms-date: Sun, 25 Sep 2011 22:50:32 GMT
        // x-ms-version: 2015-02-21

        return []
    }
}
