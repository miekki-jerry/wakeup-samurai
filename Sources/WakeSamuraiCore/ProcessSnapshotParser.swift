import Foundation

public enum ProcessSnapshotParser {
    public static func detectedAgents(from output: String, currentProcessID: Int32 = ProcessInfo.processInfo.processIdentifier) -> [DetectedAgent] {
        output
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { parseLine(String($0), currentProcessID: currentProcessID) }
            .filter { !isWakeSamuraiProcess($0) }
    }

    private static func parseLine(_ line: String, currentProcessID: Int32) -> DetectedAgent? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let parts = trimmed.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        guard parts.count >= 2, let pid = Int32(parts[0]), pid != currentProcessID else {
            return nil
        }

        let command = String(parts[1])
        let arguments = parts.count == 3 ? String(parts[2]) : ""
        let searchable = "\(command) \(arguments)".lowercased()

        guard let provider = matchedProvider(in: searchable) else {
            return nil
        }

        return DetectedAgent(id: pid, provider: provider, command: lastPathComponent(command), arguments: arguments)
    }

    private static func matchedProvider(in searchable: String) -> AgentProvider? {
        AgentProvider.allCases
            .flatMap { provider in
                provider.matchTerms.map { (provider: provider, term: $0) }
            }
            .sorted { $0.term.count > $1.term.count }
            .first { containsMatchTerm(searchable, term: $0.term) }?
            .provider
    }

    private static func containsMatchTerm(_ searchable: String, term: String) -> Bool {
        guard !term.isEmpty else { return false }

        var searchStart = searchable.startIndex
        while let range = searchable.range(of: term, range: searchStart..<searchable.endIndex) {
            let before = range.lowerBound == searchable.startIndex ? nil : searchable[searchable.index(before: range.lowerBound)]
            let after = range.upperBound == searchable.endIndex ? nil : searchable[range.upperBound]

            if isTermBoundary(before) && isTermBoundary(after) {
                return true
            }

            searchStart = range.upperBound
        }

        return false
    }

    private static func isTermBoundary(_ character: Character?) -> Bool {
        guard let character else { return true }
        return !character.isLetter && !character.isNumber
    }

    private static func lastPathComponent(_ command: String) -> String {
        URL(fileURLWithPath: command).lastPathComponent
    }

    private static func isWakeSamuraiProcess(_ agent: DetectedAgent) -> Bool {
        let searchable = "\(agent.command) \(agent.arguments)".lowercased()
        return searchable.contains("wakesamurai") || searchable.contains("wake samurai")
    }
}
