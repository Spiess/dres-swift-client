import Testing
import Foundation
@testable import DresSwiftClient

let username = "REPLACE_WITH_YOUR_USERNAME"
let password = "REPLACE_WITH_YOUR_PASSWORD"

@Test func login() async throws {
    _ = try await DresClient(url: URL(string: "https://vbs.videobrowsing.org")!, username: username, password: password)
}

@Test func listEvaluations() async throws {
    let client = try await DresClient(url: URL(string: "https://vbs.videobrowsing.org")!, username: username, password: password)
    _ = try await client.listEvaluations()
}
