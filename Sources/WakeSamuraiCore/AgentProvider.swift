import Foundation

public enum AgentProvider: String, CaseIterable, Codable, Sendable {
    case codex
    case claude
    case cursor
    case openCode
    case alibabaCodingPlan
    case alibabaTokenPlan
    case gemini
    case antigravity
    case droid
    case copilot
    case devin
    case zai
    case minimax
    case kimi
    case kimiK2
    case kilo
    case kiro
    case vertexAI
    case augment
    case amp
    case ollama
    case synthetic
    case jetBrainsAI
    case warp
    case elevenLabs
    case openRouter
    case liteLLM
    case perplexity
    case abacusAI
    case mistral
    case deepSeek
    case t3Chat
    case codebuff
    case poe
    case chutes
    case zed

    public var displayName: String {
        switch self {
        case .codex:
            "Codex"
        case .claude:
            "Claude"
        case .cursor:
            "Cursor"
        case .openCode:
            "OpenCode"
        case .alibabaCodingPlan:
            "Alibaba"
        case .alibabaTokenPlan:
            "Alibaba Token"
        case .gemini:
            "Gemini"
        case .antigravity:
            "Antigravity"
        case .droid:
            "Droid"
        case .copilot:
            "Copilot"
        case .devin:
            "Devin"
        case .zai:
            "z.ai"
        case .minimax:
            "MiniMax"
        case .kimi:
            "Kimi"
        case .kimiK2:
            "Kimi K2"
        case .kilo:
            "Kilo"
        case .kiro:
            "Kiro"
        case .vertexAI:
            "Vertex AI"
        case .augment:
            "Augment"
        case .amp:
            "Amp"
        case .ollama:
            "Ollama"
        case .synthetic:
            "Synthetic"
        case .jetBrainsAI:
            "JetBrains AI"
        case .warp:
            "Warp"
        case .elevenLabs:
            "ElevenLabs"
        case .openRouter:
            "OpenRouter"
        case .liteLLM:
            "LiteLLM"
        case .perplexity:
            "Perplexity"
        case .abacusAI:
            "Abacus AI"
        case .mistral:
            "Mistral"
        case .deepSeek:
            "DeepSeek"
        case .t3Chat:
            "T3 Chat"
        case .codebuff:
            "Codebuff"
        case .poe:
            "Poe"
        case .chutes:
            "Chutes"
        case .zed:
            "Zed"
        }
    }

    var matchTerms: [String] {
        switch self {
        case .codex:
            ["codex"]
        case .claude:
            ["claude", "claude-code"]
        case .cursor:
            ["cursor"]
        case .openCode:
            ["opencode", "open-code"]
        case .alibabaCodingPlan:
            ["alibaba", "aliyun", "qwen"]
        case .alibabaTokenPlan:
            ["bailian", "alibaba-token"]
        case .gemini:
            ["gemini"]
        case .antigravity:
            ["antigravity", "agy"]
        case .droid:
            ["droid", "factory"]
        case .copilot:
            ["copilot", "github-copilot"]
        case .devin:
            ["devin"]
        case .zai:
            ["z.ai", "zai"]
        case .minimax:
            ["minimax"]
        case .kimi:
            ["kimi", "moonshot"]
        case .kimiK2:
            ["kimi-k2", "kimik2"]
        case .kilo:
            ["kilo"]
        case .kiro:
            ["kiro", "kiro-cli"]
        case .vertexAI:
            ["vertexai", "vertex-ai", "gcloud"]
        case .augment:
            ["augment", "auggie"]
        case .amp:
            ["amp"]
        case .ollama:
            ["ollama"]
        case .synthetic:
            ["synthetic"]
        case .jetBrainsAI:
            [
                "jetbrains",
                "idea",
                "webstorm",
                "pycharm",
                "goland",
                "rubymine",
                "rider",
                "clion",
                "phpstorm",
                "datagrip",
                "dataspell",
                "aqua",
                "fleet",
            ]
        case .warp:
            ["warp"]
        case .elevenLabs:
            ["elevenlabs", "eleven-labs"]
        case .openRouter:
            ["openrouter", "open-router"]
        case .liteLLM:
            ["litellm", "lite-llm"]
        case .perplexity:
            ["perplexity"]
        case .abacusAI:
            ["abacus", "abacusai", "abacus-ai"]
        case .mistral:
            ["mistral"]
        case .deepSeek:
            ["deepseek", "deep-seek"]
        case .t3Chat:
            ["t3chat", "t3-chat"]
        case .codebuff:
            ["codebuff"]
        case .poe:
            ["poe"]
        case .chutes:
            ["chutes"]
        case .zed:
            ["zed"]
        }
    }
}
