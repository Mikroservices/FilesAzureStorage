import Foundation
import Vapor
import Crypto

final class AzureSignatureService: ServiceType {

    static func makeService(for container: Container) throws -> AzureSignatureService {
        return AzureSignatureService()
    }

    /// Signature which should be send with request to Azure.
    ///
    /// - Parameter accountName: Azure storage account name.
    /// - Parameter method: Request's method.
    /// - Parameter uri: Request's URI.
    /// - Parameter headers: Request's headers.
    /// - Returns: String to sign.
    func signature(accountName: String, method: HTTPMethod, uri: String, headers: HTTPHeaders) throws -> String {
        let message = try signableString(accountName: accountName, method: method, uri: uri, headers: headers)
        print(message)

        let secret = "/KU4W86aVIzseUTP4Uw3yDdX5vtRfkB7Q3bt15dpH0FjNmL+eG2nhJ/FODtavAI3zgfsITQR3u0wA1OS0yf2YQ=="
        let secretBase64 = Data(base64Encoded: secret, options: .ignoreUnknownCharacters)

        if let decodedSecretKey = secretBase64 {
            let signature = try HMAC.SHA256.authenticate([UInt8](message.utf8), key: [UInt8](decodedSecretKey))
            return signature.base64EncodedString(options: .lineLength64Characters)
        }

        return ""
    }

    /// Method creates string which should be signed.
    ///
    /// - Parameter accountName: Azure storage account name.
    /// - Parameter method: Request's method.
    /// - Parameter uri: Request's URI.
    /// - Parameter headers: Request's headers.
    /// - Returns: String to sign.
    private func signableString(accountName: String, method: HTTPMethod, uri: String, headers: HTTPHeaders) throws -> String {

        let canonicalizedHeaders = self.canonicalizedHeaders(headers: headers)
        let canonicalizedResource = try self.canonicalizedResource(accountName: accountName, uri: uri)

        let array : [String] = [
            method.string.uppercased(),
            headers.valueFor(name: .contentEncoding, defaultValue: ""),
            headers.valueFor(name: .contentLanguage, defaultValue: ""),
            headers.valueFor(name: .contentLength, defaultValue: "0"),
            headers.valueFor(name: .contentMD5, defaultValue: ""),
            headers.valueFor(name: .contentType, defaultValue: ""),
            headers.valueFor(name: .date, defaultValue: ""),
            headers.valueFor(name: .ifModifiedSince, defaultValue: ""),
            headers.valueFor(name: .ifMatch, defaultValue: ""),
            headers.valueFor(name: .ifNoneMatch, defaultValue: ""),
            headers.valueFor(name: .ifUnmodifiedSince, defaultValue: ""),
            headers.valueFor(name: .range, defaultValue: ""),
            canonicalizedHeaders,
            canonicalizedResource
        ]

        return array.joined(separator: "\n")
    }

    /// Method produces canonicalized headers.
    ///
    /// Example header:
    /// x-ms-date:Sat, 21 Feb 2015 00:48:38 GMT\nx-ms-version:2014-02-14
    ///
    /// - Parameter headers: Headers from request.
    /// - Returns: Canonicalized headers.
    private func canonicalizedHeaders(headers : HTTPHeaders) -> String {

        var microsoftHeaders = [String:String]()
        headers.enumerated().forEach { header in
            if (header.element.name.starts(with: "x-ms-")) {
                microsoftHeaders[header.element.name] = header.element.value
            }
        }

        let sorted = microsoftHeaders.sorted { (left, right) -> Bool in
            left.key < right.key
            }.map { header -> String in
                return "\(header.key):\(header.value)"
            }.map { header -> String in
                return header.replacingOccurrences(of: "\\s+", with: " ")
        }

        return sorted.joined(separator: "\n")
    }

    /// Method produces canonicalized resource.
    ///
    /// Example header:
    /// /myaccount/mycontainer
    /// comp:metadata
    /// restype:container
    ///
    /// - Parameter accountName: Azure storage account name.
    /// - Parameter uri: URI from path request.
    /// - Returns: Canonicalized resources.
    private func canonicalizedResource(accountName: String, uri : String) throws -> String {
        let url = URL(string: uri)
        var resource = "/" + accountName

        guard let unwrappedUrl = url else {
            throw AzureStorageError.invalidUri
        }

        resource = resource + "/" + unwrappedUrl.path

        var array = unwrappedUrl.queryParameters.map { (key, value) in
            return (key.lowercased(), value)
            }.sorted { (left, right) -> Bool in
                left.0 < right.0
            }.map { (key, value) -> String in
                let str = value.replacingOccurrences(of: "(^\\s+|\\s+$)", with: "").replacingOccurrences(of: "%3D", with: "=")
                return "\(key):\(str)"
        }

        array.insert(resource, at: 0)
        return array.joined(separator: "\n")
    }
}
