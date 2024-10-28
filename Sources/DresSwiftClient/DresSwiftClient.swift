import OpenAPIRuntime
import Foundation
import OpenAPIURLSession

public class DresClient {
    let client: Client
    let username, session: String
    
    public init(url: URL, username: String, password: String) async throws {
        self.client = Client(serverURL: url, transport: URLSessionTransport())
        
        let response = try await client.postApiV2Login(body: .json(.init(username: username, password: password)))
        
        let message = try response.ok.body.json
        
        self.username = message.username!
        self.session = message.sessionId!
    }
}
