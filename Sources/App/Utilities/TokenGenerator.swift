import Foundation

public class TokenGenerator {
    public static func generate() -> String {
        var text = ""
        let possible = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
                        "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x",
                        "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

        for _ in 1...12 {
            // text += possible.charAt(Math.floor(Math.random() * possible.length));
            let charAt = Int.random(in: 0 ..< possible.count)
            text += possible[charAt]
        }

        return text
    }
}
