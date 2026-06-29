import Foundation

public struct DetectedAgent: Identifiable, Equatable, Sendable {
    public let id: Int32
    public let provider: AgentProvider
    public let command: String
    public let arguments: String
    public let isCoding: Bool
    public let cpuUsage: Double

    public init(id: Int32, provider: AgentProvider, command: String, arguments: String, isCoding: Bool = true, cpuUsage: Double = 0) {
        self.id = id
        self.provider = provider
        self.command = command
        self.arguments = arguments
        self.isCoding = isCoding
        self.cpuUsage = cpuUsage
    }

    public var title: String {
        command.isEmpty ? provider.displayName : command
    }
}
