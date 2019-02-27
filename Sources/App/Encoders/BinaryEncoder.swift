import Vapor

public final class BinaryEncoder: DataEncoder, HTTPMessageEncoder {
    private let contentType: MediaType

    public init(_ contentType: MediaType = .binary) {
        self.contentType = contentType
    }

    /// See `DataEncoder`.
    public func encode<E>(_ encodable: E) throws -> Data where E : Encodable {
        if let data = encodable as? Data {
            return data
        }

        return Data()
    }

    /// See `HTTPMessageEncoder`.
    public func encode<E, M>(_ encodable: E, to message: inout M, on worker: Worker) throws
        where E: Encodable, M: HTTPMessage
    {
        message.contentType = self.contentType
        message.body = try HTTPBody(data: encode(encodable))
    }
}
