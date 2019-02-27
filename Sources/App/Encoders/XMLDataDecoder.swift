import Vapor
import XMLCoder

public final class XMLDataDecoder: DataDecoder, HTTPMessageDecoder {
    public func decode<D>(_ decodable: D.Type, from data: Data) throws -> D where D : Decodable {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromCapitalized

        return try decoder.decode(decodable, from: data)
    }

    public func decode<D, M>(_ decodable: D.Type, from message: M, maxSize: Int, on worker: Worker) throws -> EventLoopFuture<D> where D : Decodable, M : HTTPMessage {
        return message.body.consumeData(max: maxSize, on: worker).map { data in
            return try self.decode(D.self, from: data)
        }
    }
}
