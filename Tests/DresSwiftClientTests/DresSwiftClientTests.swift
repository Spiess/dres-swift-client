import Testing
import Foundation
@testable import DresSwiftClient

let username = "02vitrivrVR"
let password = "yuaZDFgUe4Kb"

@Test func login() async throws {
    _ = try await DresClient(url: URL(string: "https://vbs.videobrowsing.org")!, username: username, password: password)
}

@Test func listEvaluations() async throws {
    let client = try await DresClient(url: URL(string: "https://vbs.videobrowsing.org")!, username: username, password: password)
    _ = try await client.listEvaluations()
}

@Test func getCurrentTask() async throws {
    let client = try await DresClient(url: URL(string: "https://vbs.videobrowsing.org")!, username: username, password: password)
    // Get the first evaluation
    let evaluations = try await client.listEvaluations()
    let evaluation = evaluations.last!
    // Get current task
    print("Checking task of: \(evaluation.name)")
    let (name, taskGroup, taskType, duration) = try await client.getCurrentTask(evaluationId: evaluation.id)
    print("Found task \(name) in group \(taskGroup) of type \(taskType) with duration \(duration)")
}

@Test func submitItem() async throws {
    let client = try await DresClient(url: URL(string: "https://vbs.videobrowsing.org")!, username: username, password: password)
    // Get the first evaluation
    let evaluations = try await client.listEvaluations()
    let evaluation = evaluations[0]
    // Submit item
    print("Submitting item to: \(evaluation.name)")
    let response = try await client.submit(evaluationId: evaluation.id, item: "00002", start: 1000, end: 2000)
    print(response)
}

@Test func submitText() async throws {
    let client = try await DresClient(url: URL(string: "https://vbs.videobrowsing.org")!, username: username, password: password)
    let evaluations = try await client.listEvaluations()
    let evaluation = evaluations[2]
    // Submit item
    print("Submitting text item to: \(evaluation.name)")
    let response = try await client.submitText(evaluationId: evaluation.id, text: "triest")
    print(response)
}

@Test func logResults() async throws {
    let client = try await DresClient(url: URL(string: "https://vbs.videobrowsing.org")!, username: username, password: password)
    let evaluations = try await client.listEvaluations()
    let evaluation = evaluations.first!
    // Log results
    print("Logging results to: \(evaluation.name)")
    let status = try await client.logResults(evaluationId: evaluation.id, timestamp: 1000, sortType: "Similarity", resultSetAvailability: "Very", results: [("test", 1000, 2000)], events: [(2000, "BROWSING", "test", "test value")])
    print(status)
    #expect(status)
}
