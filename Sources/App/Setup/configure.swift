import Vapor
import ExtendedError

public final class BinaryEncoder: DataEncoder, HTTPMessageEncoder {
    /// The specific plaintext `MediaType` to use.
    private let contentType: MediaType

    /// Creates a new `PlaintextEncoder`.
    ///
    /// - parameters:
    ///     - contentType: Plaintext `MediaType` to use.
    ///                    Usually `.plainText` or `.html`.
    public init(_ contentType: MediaType = .binary) {
        self.contentType = contentType
    }

    /// See `DataEncoder`.
    public func encode<E>(_ encodable: E) throws -> Data where E : Encodable {
        let data =  encodable as! Data

         // var preparedBody = "\n".convertToData()
         // preparedBody.append(data)

        return data
    }

    /// See `HTTPMessageEncoder`.
    public func encode<E, M>(_ encodable: E, to message: inout M, on worker: Worker) throws
        where E: Encodable, M: HTTPMessage
    {
        message.contentType = self.contentType
        message.body = try HTTPBody(data: encode(encodable))
    }
}

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    // Register settings storage service.
    try registerSettingsStorage(services: &services)

    /// Register routes to the router.
    try registerRoutes(services: &services)

    /// Register custom services.
    registerServices(services: &services)

    /// Register middleware.
    registerMiddlewares(services: &services)

    var contentConfig = ContentConfig.default()
    contentConfig.use(encoder: BinaryEncoder(), for: .binary)
    services.register(contentConfig)
}

private func registerSettingsStorage(services: inout Services) throws {
    guard let publicKey = Environment.get("LETTERER_PUBLIC_KEY") else { throw Abort(.internalServerError) }
    guard let azureStorageSecretKey = Environment.get("LETTERER_AZURE_STORAGE_SECRET_KEY") else { throw Abort(.internalServerError) }
    guard let azureStorageAccountName = Environment.get("LETTERER_AZURE_STORAGE_ACCOUNT_NAME") else { throw Abort(.internalServerError) }

    services.register { container -> SettingsStorage in
        let publicKeyWithNewLines = publicKey.replacingOccurrences(of: "<br>", with: "\n")
        return SettingsStorage(publicKey: publicKeyWithNewLines, azureStorageSecretKey: azureStorageSecretKey, azureStorageAccountName: azureStorageAccountName)
    }
}

private func registerRoutes(services: inout Services) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}

private func registerServices(services: inout Services) {
    services.register(AuthorizationService.self)
    services.register(AzureStorageService.self)
    services.register(AzureSignatureService.self)
}

private func registerMiddlewares(services: inout Services) {
    var middlewares = MiddlewareConfig()

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)

    // Catches errors and converts to HTTP response
    services.register(CustomErrorMiddleware.self)
    middlewares.use(CustomErrorMiddleware.self)
    
    services.register(middlewares)
}
