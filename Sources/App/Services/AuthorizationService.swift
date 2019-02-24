import Vapor
import JWT
import Crypto

final class AuthorizationService: ServiceType {

    static func makeService(for worker: Container) throws -> AuthorizationService {
        return AuthorizationService()
    }

    public func getUserIdFromBearerToken(request: Request) throws -> UUID? {
        guard let authorizationPayload = try self.geAuthorizationPayloadFromBearerToken(request: request) else {
            return nil
        }

        return authorizationPayload.id
    }

    public func getUserNameFromBearerToken(request: Request) throws -> String? {
        guard let authorizationPayload = try self.geAuthorizationPayloadFromBearerToken(request: request) else {
            return nil
        }

        return authorizationPayload.userName
    }

    private func geAuthorizationPayloadFromBearerToken(request: Request) throws -> AuthorizationPayload? {

        if let bearer = request.http.headers.bearerAuthorization {

            let settingsStorage = try request.make(SettingsStorage.self)
            let rsaKey: RSAKey = try .public(pem: settingsStorage.publicKey)
            let authorizationPayload = try JWT<AuthorizationPayload>(from: bearer.token, verifiedUsing: JWTSigner.rs512(key: rsaKey))

            if authorizationPayload.payload.exp > Date() {
                return authorizationPayload.payload
            }
        }

        return nil
    }
}
