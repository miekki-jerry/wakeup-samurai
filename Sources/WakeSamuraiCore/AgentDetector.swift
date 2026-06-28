import Foundation
import Darwin

public protocol ProcessListing: Sendable {
    func processSnapshot() throws -> String
}

public struct ShellProcessListing: ProcessListing {
    public init() {}

    public func processSnapshot() throws -> String {
        var fileDescriptors = [Int32](repeating: 0, count: 2)
        guard pipe(&fileDescriptors) == 0 else {
            return ""
        }

        var actions: posix_spawn_file_actions_t?
        posix_spawn_file_actions_init(&actions)
        defer { posix_spawn_file_actions_destroy(&actions) }

        posix_spawn_file_actions_adddup2(&actions, fileDescriptors[1], STDOUT_FILENO)
        posix_spawn_file_actions_addclose(&actions, fileDescriptors[0])

        var processID = pid_t()
        var arguments: [UnsafeMutablePointer<CChar>?] = [
            strdup("/bin/ps"),
            strdup("-axo"),
            strdup("pid=,comm=,args="),
            nil
        ]
        defer {
            for argument in arguments where argument != nil {
                free(argument)
            }
        }

        let spawnResult = posix_spawn(&processID, "/bin/ps", &actions, nil, &arguments, nil)
        close(fileDescriptors[1])

        guard spawnResult == 0 else {
            close(fileDescriptors[0])
            return ""
        }

        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while true {
            let bytesRead = read(fileDescriptors[0], &buffer, buffer.count)
            if bytesRead > 0 {
                data.append(buffer, count: bytesRead)
            } else {
                break
            }
        }
        close(fileDescriptors[0])

        var status: Int32 = 0
        waitpid(processID, &status, 0)

        return String(decoding: data, as: UTF8.self)
    }
}

public struct AgentDetector: Sendable {
    private let processListing: any ProcessListing

    public init(processListing: any ProcessListing = ShellProcessListing()) {
        self.processListing = processListing
    }

    public func detectedAgents() throws -> [DetectedAgent] {
        let snapshot = try processListing.processSnapshot()
        let agents = ProcessSnapshotParser.detectedAgents(from: snapshot)
        return AgentProvider.allCases.compactMap { provider in
            agents.first { $0.provider == provider }
        }
    }
}
