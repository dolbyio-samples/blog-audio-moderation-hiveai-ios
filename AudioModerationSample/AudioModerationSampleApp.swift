import SwiftUI
import VoxeetSDK

@main
struct AudioModerationSampleApp: App {

    init() {
        initializeSDK()
    }

    var body: some Scene {
        WindowGroup {
            ConferenceView()
        }
    }

    private func initializeSDK() {
        // Initialize the Voxeet SDK
        // Please read the documentation at:
        // https://docs.dolby.io/communications-apis/docs/initializing-ios
        // Generate a client access token from the Dolby.io dashboard and insert into accessToken variable
        let accessToken = "ClientAccessToken"
        VoxeetSDK.shared.initialize(accessToken: accessToken) { closure, isExpired in
            closure(accessToken)
        }

        // Example of public variables to change the conference behavior.
        VoxeetSDK.shared.notification.push.type = .none
        VoxeetSDK.shared.conference.defaultBuiltInSpeaker = true
        VoxeetSDK.shared.conference.defaultVideo = false
    }
}
