// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "FilesAzureStorage",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.2.2"),

        // 🔏 JSON Web Token signing and verification (HMAC, RSA).
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),

        // 📄 XMLEncoder & XMLDecoder using Codable protocol in Swift 4.
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.3.1"),

        // 🐞 Custom error middleware for Vapor.
        .package(url: "https://github.com/Letterer/ExtendedError.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "JWT", "XMLCoder", "ExtendedError"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

