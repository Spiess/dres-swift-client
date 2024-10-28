import Testing
import Foundation
@testable import DresSwiftClient

let username = "REPLACE_WITH_YOUR_USERNAME"
let password = "REPLACE_WITH_YOUR_PASSWORD"

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    _ = try await DresClient(url: URL(string: "https://vbs.videobrowsing.org")!, username: username, password: password)
}
