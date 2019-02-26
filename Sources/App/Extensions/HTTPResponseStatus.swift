import Foundation
import Vapor

extension HTTPResponseStatus {
    func isSuccess() -> Bool {
        return self.code >= 200 && self.code < 300
    }
}
