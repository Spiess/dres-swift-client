import OpenAPIRuntime
import Foundation
import OpenAPIURLSession

struct TaskAnswer: Codable {
    let mediaItemName: String
    let start: Int64
    let end: Int64
}

public struct DresClient : Sendable {
    let client: Client
    let username, session: String
    let url: URL
    
    /// Instantiate client and perform login.
    public init(url: URL, username: String, password: String) async throws {
        self.client = Client(serverURL: url, transport: URLSessionTransport())
        
        let response = try await client.postApiV2Login(body: .json(.init(username: username, password: password)))
        
        let message = try response.ok.body.json
        
        self.username = message.username!
        self.session = message.sessionId!
        
        self.url = url
    }
    
    /// Retrieves and lists the evaluations currently available to this client.
    ///
    /// - Returns: Array of tuples containing the name and ID of each evaluation.
    public func listEvaluations() async throws -> [(name: String, id: String)] {
        let response = try await client.getApiV2ClientEvaluationList(.init(query: .init(session: session)))
        
        let message = try response.ok.body.json
        
        return message.map { ($0.name, $0.id) }
    }
    
    /// Retrieves information about the current active task of the specified evaluation.
    /// If the evaluation has no active task, an error is thrown.
    ///
    /// - Parameters:
    ///   - evaluationId: The ID of the evaluation to retrieve active task information for.
    ///
    /// - Returns: Tuple of task name, task group, task type and duraction in seconds.
    public func getCurrentTask(evaluationId: String) async throws -> (name: String, taskGroup: String, taskType: String, duration: Int64) {
        let response = try await client.getApiV2ClientEvaluationCurrentTaskByEvaluationId(
            path: .init(evaluationId: evaluationId),
            query: .init(session: session)
        )
        
        let message = try response.ok.body.json
        
        return (message.name, message.taskGroup, message.taskType, message.duration)
    }
    
    /// Submits the specified item to the specified evaluation.
    ///
    /// - Parameters:
    ///   - evaluationId: The ID of the evaluation to retrieve active task information for.
    ///   - item: The ID of the item to submit.
    ///   - start: Optional start timestamp.
    ///   - end: Optional end timestamp.
    ///
    /// - Returns: Tuple of submission status and description.
    @available(macOS 13.0, *)
    public func submit(evaluationId: String, item: String, start: Int64? = nil, end: Int64? = nil) async throws -> (status: Bool, description: String) {
        var request = URLRequest(url: url.appending(path: "api/v2/submit").appending(path: evaluationId).appending(queryItems: [.init(name: "session", value: session)]))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONEncoder().encode(["answerSets": [["answers": [TaskAnswer(mediaItemName: item, start: start!, end: end!)]]]])
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("Response JSON: \(jsonResponse)")
        } else {
            print("Invalid JSON format")
        }
        return (false, "TODO")
    }
    
    /// Submits the specified text to the specified evaluation.
    ///
    /// - Parameters:
    ///   - evaluationId: The ID of the evaluation to retrieve active task information for.
    ///   - text: The text to submit
    ///
    /// - Returns: Tuple of submission status and description.
    public func submitText(evaluationId: String, text: String) async throws -> (status: Bool, description: String) {
        let response = try await client.postApiV2SubmitByEvaluationId(
            path: .init(evaluationId: evaluationId),
            query: .init(session: session),
            body: .json(
                .init(answerSets: [.init(
                    answers: [.init(text: text)]
                )])
            )
        )
        
        switch response {
        case .ok(let ok):
            let message = try ok.body.json
            return (message.status, message.description)
        case .accepted(let accepted):
            let message = try accepted.body.json
            return (message.status, message.description)
        case .badRequest(let badRequest):
            let message = try badRequest.body.json
            return (message.status, message.description)
        case .unauthorized(let unauthorized):
            let message = try unauthorized.body.json
            return (message.status, message.description)
        case .notFound(let notFound):
            let message = try notFound.body.json
            return (message.status, message.description)
        case .preconditionFailed(let preconditionFailed):
            let message = try preconditionFailed.body.json
            return (message.status, message.description)
        case .undocumented(statusCode: _, let undocumented):
            let message = undocumented.body
            return (false, "\(String(describing: message))")
        }
    }
    
    public func logResults(evaluationId: String, timestamp: Int64, sortType: String, resultSetAvailability: String, results: [(mediaItem: String, start: Int64, end: Int64)], events: [(timestamp: Int64, category: String, _type: String, value: String)]) async throws -> Bool {
        let response = try await client.postApiV2LogResultByEvaluationId(
            path: .init(evaluationId: evaluationId),
            query: .init(session: session),
            body: .json(.init(
                timestamp: timestamp,
                sortType: sortType,
                resultSetAvailability: resultSetAvailability,
                results: results.map {.init(answer: .init(mediaItemName: $0.mediaItem, start: $0.start, end: $0.end))},
                events: events.map {.init(timestamp: $0.timestamp, category: .init(rawValue: $0.category) ?? .OTHER, _type: $0._type, value: $0.value)}))
        )
        
        let message = try response.ok.body.json
        
        return message.status
    }
}
