import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    // Basic response.
    router.get { _ in
        return "Service is up and running!"
    }

    // Configuring controllers.
    try router.register(collection: FilesController())
}
