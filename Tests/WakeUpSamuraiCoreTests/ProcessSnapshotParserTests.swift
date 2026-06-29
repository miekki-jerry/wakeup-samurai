import Testing
@testable import WakeUpSamuraiCore

private struct StubProcessListing: ProcessListing {
    let output: String

    func processSnapshot() throws -> String {
        output
    }
}

@Test func detectsCodexFromCommandArguments() {
    let output = """
      101 /opt/homebrew/bin/node node /opt/homebrew/bin/codex --ask-for-approval never
      102 /usr/bin/login login -fp user
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents == [
        DetectedAgent(id: 101, provider: .codex, command: "node", arguments: "node /opt/homebrew/bin/codex --ask-for-approval never")
    ])
    #expect(agents.first?.isCoding == true)
}

@Test func detectsClaudeFromBinaryName() {
    let output = """
      201 /Users/me/.local/bin/claude claude --dangerously-skip-permissions
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.first?.provider == .claude)
    #expect(agents.first?.id == 201)
}

@Test func detectsIdleCodexDesktopAppWithoutCoding() {
    let output = """
      55508 /Applications/Co /Applications/Codex.app/Contents/MacOS/Codex
      55875 /Applications/Co /Applications/Codex.app/Contents/Resources/codex app-server --analytics-default-enabled
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.map { $0.provider } == [.codex, .codex])
    #expect(agents.allSatisfy { !$0.isCoding })
}

@Test func detectsActiveCodexDesktopAppFromCpuUsage() {
    let output = """
      55508 0.0 /Applications/Co /Applications/Codex.app/Contents/MacOS/Codex
      55875 8.5 /Applications/Co /Applications/Codex.app/Contents/Resources/codex app-server --analytics-default-enabled
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.map { $0.provider } == [.codex, .codex])
    #expect(agents.map { $0.isCoding } == [false, true])
    #expect(agents.last?.cpuUsage == 8.5)
}

@Test func ignoresCurrentProcessAndWakeUpSamuraiItself() {
    let output = """
      301 /tmp/WakeUpSamurai WakeUpSamurai
      302 /opt/homebrew/bin/codex codex
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 302)

    #expect(agents.isEmpty)
}

@Test func detectsAdditionalCodexBarProviders() {
    let output = """
      401 /Users/me/.local/bin/kimi kimi
      402 /opt/homebrew/bin/gemini gemini --prompt hello
      403 /Users/me/.local/bin/agy agy
      404 /usr/local/bin/auggie auggie
      405 /opt/homebrew/bin/kiro-cli kiro-cli chat --no-interactive /usage
      406 /Applications/Zed.app/Contents/MacOS/zed zed .
      407 /Applications/Cursor.app/Contents/MacOS/Cursor Cursor
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.map { $0.provider } == [
        .kimi,
        .gemini,
        .antigravity,
        .augment,
        .kiro,
        .zed,
        .cursor,
    ])
}

@Test func detectsKimiCodeAppProcess() {
    let output = """
      410 Kimi Code Kimi Code
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents == [
        DetectedAgent(id: 410, provider: .kimi, command: "Kimi", arguments: "Code Kimi Code")
    ])
    #expect(agents.first?.isCoding == true)
}

@Test func detectsKimiDesktopAppWithoutCoding() {
    let output = """
      411 /Applications/Ki /Applications/Kimi Code.app/Contents/MacOS/Kimi Code
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.map { $0.provider } == [.kimi])
    #expect(agents.allSatisfy { !$0.isCoding })
}

@Test func detectsCursorDesktopHelpersWithoutCoding() {
    let output = """
      441 /Applications/Cu /Applications/Cursor.app/Contents/MacOS/Cursor
      442 Cursor Helper: m Cursor Helper: mcp-process
      443 Cursor Helper: t Cursor Helper: terminal pty-host
      444 Cursor Helper (P Cursor Helper (Plugin): extension-host (agent-exec) yuni [2-8]
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.map { $0.provider } == [.cursor, .cursor, .cursor, .cursor])
    #expect(agents.allSatisfy { !$0.isCoding })
}

@Test func ignoresSystemCursorUIViewService() {
    let output = """
      445 0.0 /System/Library/ /System/Library/PrivateFrameworks/TextInputUIMacHelper.framework/Versions/A/XPCServices/CursorUIViewService.xpc/Contents/MacOS/CursorUIViewService
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.isEmpty)
}

@Test func detectsCodexAppServerWithoutCoding() {
    let output = """
      451 /Users/piter/.cursor/extensions/openai.chatgpt/bin/codex codex app-server --analytics-default-enabled
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.map { $0.provider } == [.cursor])
    #expect(agents.allSatisfy { !$0.isCoding })
}

@Test func marksMultipleCliAgentsAsCoding() {
    let output = """
      421 /opt/homebrew/bin/codex codex
      422 /Users/me/.local/bin/kimi kimi
      423 /Applications/Co /Applications/Codex.app/Contents/MacOS/Codex
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.filter(\.isCoding).map { $0.provider } == [.codex, .kimi])
    #expect(agents.filter { !$0.isCoding }.map { $0.provider } == [.codex])
}

@Test func detectorPrefersCodingProcessForSameProvider() throws {
    let output = """
      431 /Applications/Co /Applications/Codex.app/Contents/MacOS/Codex
      432 /opt/homebrew/bin/codex codex
    """
    let detector = AgentDetector(processListing: StubProcessListing(output: output))

    let agents = try detector.detectedAgents()

    #expect(agents == [
        DetectedAgent(id: 432, provider: .codex, command: "codex", arguments: "codex")
    ])
}

@Test func matchesProviderTermsOnTokenBoundaries() {
    let output = """
      501 /usr/bin/node node optimized-renderer.js
      502 /usr/bin/python python poetry-helper.py
      503 /usr/bin/python python ampere-report.py
      504 /Applications/Zed.app/Contents/MacOS/zed zed .
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.map { $0.provider } == [.zed])
}

@Test func ignoresSystemAquaProcess() {
    let output = """
      601 /usr/libexec/UserEventAgent /usr/libexec/UserEventAgent (Aqua)
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.isEmpty)
}

@Test func ignoresJetBrainsTextInShellCommands() {
    let output = """
      610 /bin/zsh /bin/zsh -lc ps ax | rg -i 'jetbrains|intellij|aqua'
      611 /opt/homebrew/bin/rg rg -i jetbrains
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.isEmpty)
}

@Test func ignoresProviderTermsInInspectorProcesses() {
    let terms = AgentProvider.allCases.flatMap(\.matchTerms).joined(separator: " ")
    let output = """
      620 /bin/zsh /bin/zsh -lc echo '\(terms)'
      621 /opt/homebrew/bin/rg rg -i '\(terms)'
      622 /usr/bin/grep grep -i '\(terms)'
      623 /bin/ps ps ax -o pid=,comm=,args= \(terms)
      624 /usr/bin/git git commit -m '\(terms)'
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.isEmpty)
}

@Test func detectsAgentCliLaunchedThroughNodeWrapper() {
    let output = """
      630 /opt/homebrew/bin/node node /opt/homebrew/bin/codex --ask-for-approval never
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.first?.provider == .codex)
}

@Test func detectsJetBrainsAppsFromAppBundlePaths() {
    let output = """
      701 /Applications/Aqua.app/Contents/MacOS/aqua /Applications/Aqua.app/Contents/MacOS/aqua
      702 /Applications/IntelliJ IDEA.app/Contents/MacOS/idea /Applications/IntelliJ IDEA.app/Contents/MacOS/idea
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.map { $0.provider } == [.jetBrainsAI, .jetBrainsAI])
}
