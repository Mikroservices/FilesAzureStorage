import Vapor

extension HTTPHeaders {
    public func valueFor(name header: HTTPHeaderName, defaultValue: String) -> String {
        if self.contains(name: header) {
            return self.firstValue(name: header) ?? defaultValue
        }

        return defaultValue
    }
}
