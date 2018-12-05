import Foundation
import PromiseKit

struct Dependency: Equatable, Codable {
    public let name: String
    public let gitPath: String
    public let version: VersionSpecifier

    public init(name: String, gitPath: String, version: VersionSpecifier) {
        self.name = name
        self.gitPath = gitPath
        self.version = version
    }

    func fetchManifest() -> Promise<Manifest> {
        return firstly {
            return Guarantee.value(GitRepository(path: gitPath))
        }.then { (gitRepo: GitRepository) -> Promise<Manifest> in
            let commit = try gitRepo.latestCompatibleCommit(forVersion: self.version)
            return gitRepo.fetchManifest(commit: commit)
        }
    }
}
