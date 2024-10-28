import OpenAPIRuntime
import Foundation
import OpenAPIURLSession

public class DresClient {
    let client: Client
    let username, session: String
    
    /// Instantiate client and perform login.
    public init(url: URL, username: String, password: String) async throws {
        self.client = Client(serverURL: url, transport: URLSessionTransport())
        
        let response = try await client.postApiV2Login(body: .json(.init(username: username, password: password)))
        
        let message = try response.ok.body.json
        
        self.username = message.username!
        self.session = message.sessionId!
    }
    
    /// Retrieves and lists the evaluations currently available to this client.
    ///
    /// - Returns: Array of tuples containing the name and ID of each evaluation.
    public func listEvaluations() async throws -> [(name: String, id: String)] {
        let response = try await client.getApiV2ClientEvaluationList(.init(query: .init(session: session)))
        
        let message = try response.ok.body.json
        
        return message.map { ($0.name, $0.id) }
    }
}
