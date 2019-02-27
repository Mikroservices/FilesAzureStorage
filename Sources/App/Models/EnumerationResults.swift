import Vapor

public final class EnumerationResults {
    var blobs: Blobs?

    init(blobs: Blobs?) {
        self.blobs = blobs
    }
}

extension EnumerationResults: Content { }
