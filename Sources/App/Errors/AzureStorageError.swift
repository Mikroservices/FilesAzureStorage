import Vapor
import ExtendedError

enum AzureStorageError: String, Error {
    case invalidUri
}

extension AzureStorageError: TerminateError {
    var status: HTTPResponseStatus {
        return .badRequest
    }

    var reason: String {
        switch self {
        case .invalidUri: return "Invalid URI was specified."
        }
    }

    var identifier: String {
        return "azureStorage"
    }

    var code: String {
        return self.rawValue
    }
}
