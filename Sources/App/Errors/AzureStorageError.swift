import Vapor
import ExtendedError

enum AzureStorageError: String, Error {
    case invalidUri
    case fileNotCreated
    case filePropertiesNotReaded
}

extension AzureStorageError: TerminateError {
    var status: HTTPResponseStatus {
        return .badRequest
    }

    var reason: String {
        switch self {
        case .invalidUri: return "Invalid URI was specified."
        case .fileNotCreated: return "File wasn't created"
        case .filePropertiesNotReaded: return "Error during read file properties"
        }
    }

    var identifier: String {
        return "azureStorage"
    }

    var code: String {
        return self.rawValue
    }
}
