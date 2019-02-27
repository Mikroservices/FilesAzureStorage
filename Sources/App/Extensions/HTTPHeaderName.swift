import Vapor

extension HTTPHeaderName {
    public static let xMsVersion = HTTPHeaderName("x-ms-version")
    public static let xMsDate = HTTPHeaderName("x-ms-date")
    public static let xMsBlobType = HTTPHeaderName("x-ms-blob-type")
    public static let xMsBlobPublicAccess = HTTPHeaderName("x-ms-blob-public-access")
    public static let xMsBlobContentType = HTTPHeaderName("x-ms-blob-content-type")
}
