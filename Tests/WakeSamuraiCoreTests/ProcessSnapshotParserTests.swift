import Testing
@testable import WakeSamuraiCore

@Test func detectsCodexFromCommandArguments() {
    let output = """
      101 /opt/homebrew/bin/node node /opt/homebrew/bin/codex --ask-for-approval never
      102 /usr/bin/login login -fp user
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents == [
        DetectedAgent(id: 101, provider: .codex, command: "node", arguments: "node /opt/homebrew/bin/codex --ask-for-approval never")
    ])
}

@Test func detectsClaudeFromBinaryName() {
    let output = """
      201 /Users/me/.local/bin/claude claude --dangerously-skip-permissions
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.first?.provider == .claude)
    #expect(agents.first?.id == 201)
}

@Test func detectsCodexDesktopAppFromProcessArguments() {
    let output = """
      55508 /Applications/Co /Applications/Codex.app/Contents/MacOS/Codex
      55875 /Applications/Co /Applications/Codex.app/Contents/Resources/codex app-server --analytics-default-enabled
    """

    let agents = ProcessSnapshotParser.detectedAgents(from: output, currentProcessID: 999)

    #expect(agents.map { $0.provider } == [.codex, .codex])
}

@Test func ignoresCurrentProcessAndWakeSamuraiItself() {
    let output = """
      301 /tmp/WakeSamurai WakeSamurai
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
