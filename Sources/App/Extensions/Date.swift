import Foundation

public struct RFC1123USLocale {
    public static let shared = RFC1123USLocale()
    public let formatter: DateFormatter

    public init() {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        formatter.locale = Locale(identifier: "en-US")
        self.formatter = formatter
    }
}

extension Date {
    public var rfc1123US: String {
        return RFC1123USLocale.shared.formatter.string(from: self)
    }

    public init?(rfc1123US: String) {
        guard let date = RFC1123USLocale.shared.formatter.date(from: rfc1123US) else {
            return nil
        }

        self = date
    }
}
