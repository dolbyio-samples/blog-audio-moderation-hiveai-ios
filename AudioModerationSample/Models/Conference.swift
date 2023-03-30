import Foundation
import VoxeetSDK

final class Conference: ObservableObject {

    @Published private(set) var participants: String = "-"
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String = ""

    init() {
        VoxeetSDK.shared.conference.delegate = self
    }

    func join(conferenceName: String?, userName: String?) {
        isLoading = true
        UserDefaults.conferenceName = conferenceName
        UserDefaults.userName = userName
        openSession(userName: userName) { [weak self] error in
            if error == nil {
                let options = VTConferenceOptions()
                options.alias = conferenceName
                VoxeetSDK.shared.conference.create(options: options) { conference in
                    VoxeetSDK.shared.conference.join(conference: conference) { [weak self] conference in
                        guard let self = self else { return }
                        self.errorMessage = ""
                        self.isConnected = true
                        self.isLoading = false
                    } fail: { [weak self] error in
                        self?.handle(error: error)
                    }
                } fail: { [weak self] error in
                    self?.handle(error: error)
                }
            } else {
                self?.handle(error: error)
            }
        }
    }

    func leave() {
        isLoading = true
        VoxeetSDK.shared.conference.leave { [weak self] error in
            self?.handle(error: error)
        }
    }

    private func openSession(userName: String?, completion: @escaping (Error?) -> Void) {
        VoxeetSDK.shared.session.close { _ in
            let info = VTParticipantInfo(externalID: nil, name: userName, avatarURL: nil)
            VoxeetSDK.shared.session.open(info: info) { error in
                completion(error)
            }
        }
    }

    private func handle(error: Error?) {
        isLoading = false
        isConnected = false
        errorMessage = error?.localizedDescription ?? ""
    }
}

// MARK: - VTConferenceDelegate
extension Conference: VTConferenceDelegate {

    func statusUpdated(status: VTConferenceStatus) {}
    func permissionsUpdated(permissions: [Int]) {}
    func participantAdded(participant: VTParticipant) {}
    func participantUpdated(participant: VTParticipant) {}

    func streamAdded(participant: VTParticipant, stream: MediaStream) {
        updateParticipantNames()
    }
    func streamUpdated(participant: VTParticipant, stream: MediaStream) {
        updateParticipantNames()
    }
    func streamRemoved(participant: VTParticipant, stream: MediaStream) {
        updateParticipantNames()
    }

    private func updateParticipantNames() {
        participants = VoxeetSDK.shared.conference.current?.participants
            .filter({ $0.streams.isEmpty == false })
            .map({ $0.info.name ?? "" })
            .map { $0.isEmpty ? "Unknown" : $0 }
            .joined(separator: ", ") ?? "-"
    }
}

