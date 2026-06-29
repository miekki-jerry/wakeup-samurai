import Foundation

public enum ProcessSnapshotParser {
    public static func detectedAgents(from output: String, currentProcessID: Int32 = ProcessInfo.processInfo.processIdentifier) -> [DetectedAgent] {
        output
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { parseLine(String($0), currentProcessID: currentProcessID) }
            .filter { !isWakeUpSamuraiProcess($0) }
    }

    private static func parseLine(_ line: String, currentProcessID: Int32) -> DetectedAgent? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let parts = trimmed.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        guard parts.count >= 2, let pid = Int32(parts[0]), pid != currentProcessID else {
            return nil
        }

        let processFields = parseProcessFields(parts: parts)
        let command = processFields.command
        let arguments = processFields.arguments
        let cpuUsage = processFields.cpuUsage
        guard !isIgnoredProcess(command: command, arguments: arguments) else {
            return nil
        }

        guard let provider = matchedProvider(command: command, arguments: arguments) else {
            return nil
        }

        return DetectedAgent(
            id: pid,
            provider: provider,
            command: lastPathComponent(command),
            arguments: arguments,
            isCoding: isCodingProcess(provider: provider, command: command, arguments: arguments, cpuUsage: cpuUsage),
            cpuUsage: cpuUsage
        )
    }

    private static func parseProcessFields(parts: [Substring]) -> (cpuUsage: Double, command: String, arguments: String) {
        if parts.count == 3 {
            let second = String(parts[1])
            let remainder = String(parts[2])
            let remainderParts = remainder.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)

            if let cpuUsage = Double(second), let command = remainderParts.first {
                return (
                    cpuUsage: cpuUsage,
                    command: String(command),
                    arguments: remainderParts.count == 2 ? String(remainderParts[1]) : ""
                )
            }
        }

        return (
            cpuUsage: 0,
            command: String(parts[1]),
            arguments: parts.count == 3 ? String(parts[2]) : ""
        )
    }

    private static func matchedProvider(command: String, arguments: String) -> AgentProvider? {
        if isJetBrainsAppProcess(command: command, arguments: arguments) {
            return .jetBrainsAI
        }

        if let provider = matchedProvider(in: command) {
            return provider
        }

        guard !ignoresArguments(for: command) else {
            return nil
        }

        let argumentSearchable = executableArgumentSearchable(command: command, arguments: arguments)
        guard !argumentSearchable.isEmpty else {
            return nil
        }

        return matchedProvider(in: argumentSearchable)
    }

    private static func matchedProvider(in searchable: String) -> AgentProvider? {
        AgentProvider.allCases
            .filter { $0 != .jetBrainsAI }
            .flatMap { provider in
                provider.matchTerms.map { (provider: provider, term: $0) }
            }
            .sorted { $0.term.count > $1.term.count }
            .first { containsMatchTerm(searchable.lowercased(), term: $0.term) }?
            .provider
    }

    private static func isJetBrainsAppProcess(command: String, arguments: String) -> Bool {
        let searchable = "\(command) \(arguments)".lowercased()
        let appBundlePaths = [
            "/applications/intellij idea.app/contents/macos/",
            "/applications/webstorm.app/contents/macos/",
            "/applications/pycharm.app/contents/macos/",
            "/applications/goland.app/contents/macos/",
            "/applications/rubymine.app/contents/macos/",
            "/applications/rider.app/contents/macos/",
            "/applications/clion.app/contents/macos/",
            "/applications/phpstorm.app/contents/macos/",
            "/applications/datagrip.app/contents/macos/",
            "/applications/dataspell.app/contents/macos/",
            "/applications/aqua.app/contents/macos/",
            "/applications/fleet.app/contents/macos/",
            "/applications/jetbrains toolbox.app/contents/macos/",
        ]

        return appBundlePaths.contains { searchable.contains($0) }
    }

    private static func ignoresArguments(for command: String) -> Bool {
        let processName = lastPathComponent(command).lowercased()
        let ignoredProcessNames: Set<String> = [
            "awk",
            "bash",
            "cat",
            "egrep",
            "fgrep",
            "find",
            "fish",
            "git",
            "grep",
            "head",
            "less",
            "login",
            "mdfind",
            "osascript",
            "ps",
            "rg",
            "sed",
            "sh",
            "tail",
            "tee",
            "tmux",
            "xargs",
            "zsh",
        ]

        return ignoredProcessNames.contains(processName)
    }

    private static func executableArgumentSearchable(command: String, arguments: String) -> String {
        let processName = lastPathComponent(command).lowercased()
        let tokens = arguments.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard !tokens.isEmpty else { return "" }

        let wrapperProcessNames: Set<String> = [
            "bun",
            "deno",
            "node",
            "npm",
            "npx",
            "pnpm",
            "python",
            "python3",
            "uv",
            "uvx",
        ]

        if wrapperProcessNames.contains(processName) {
            return tokens
                .prefix(8)
                .filter { !$0.hasPrefix("-") }
                .joined(separator: " ")
        }

        return tokens[0]
    }

    private static func isCodingProcess(provider: AgentProvider, command: String, arguments: String, cpuUsage: Double) -> Bool {
        if isDesktopRuntimeProcess(command: command, arguments: arguments) {
            return provider == .codex && cpuUsage >= 1
        }

        return true
    }

    private static func isDesktopRuntimeProcess(command: String, arguments: String) -> Bool {
        let searchable = "\(command) \(arguments)".lowercased()
        return searchable.contains(".app/contents/")
            || searchable.contains("cursor helper")
            || searchable.contains(" app-server")
    }

    private static func isIgnoredProcess(command: String, arguments: String) -> Bool {
        let searchable = "\(command) \(arguments)".lowercased()
        return searchable.contains("cursoruiviewservice")
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

    private static func isWakeUpSamuraiProcess(_ agent: DetectedAgent) -> Bool {
        let searchable = "\(agent.command) \(agent.arguments)".lowercased()
        return searchable.contains("wakeupsamurai")
            || searchable.contains("wakeup samurai")
            || searchable.contains("wake samurai")
    }
}
