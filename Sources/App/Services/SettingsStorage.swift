import Foundation
import Vapor

struct SettingsStorage: Service {
    let publicKey: String
    let azureStorageSecretKey: String
    let azureStorageAccountName: String
}
