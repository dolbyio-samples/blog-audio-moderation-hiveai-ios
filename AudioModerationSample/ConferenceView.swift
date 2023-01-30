import SwiftUI

struct ConferenceView: View {

    @State var conferenceName: String = ""
    @State var userName: String = ""

    // Conference Model that uses the Dolby.io Comms SDK
    @StateObject var conference = Conference()
    // AudioRecorder that records the last 10 seconds
    @StateObject var audioRecorder = AudioRecorder()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Text("Dolby.io Conference With Hive's Audio Moderation")
                    .font(.title)

                VStack(alignment: .leading) {
                    Divider()
                        .padding(.bottom)
                    Text("Participants:")
                        .font(.headline)
                    Text(conference.participants)
                    Divider()
                        .padding(.bottom)
                }

                TextField("Conference Name", text: $conferenceName)
                    .padding()
                    .background(Color.textFieldBackground)
                    .cornerRadius(5.0)
                HStack {
                    TextField("Username", text: $userName)
                        .padding()
                        .background(Color.textFieldBackground)
                        .cornerRadius(5.0)
                    Button(conference.isConnected ? "Leave" : "Join") {
                        if conference.isConnected {
                            audioRecorder.stop()
                            conference.leave()
                        } else {
                            audioRecorder.start()
                            conference.join(
                                conferenceName: conferenceName,
                                userName: userName
                            )
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 90, height: 50)
                    .background(Color.accent)
                    .cornerRadius(5.0)
                    .disabled(conference.isLoading)
                }
                Text(conference.errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

struct ConferenceView_Previews: PreviewProvider {
    static var previews: some View {
        ConferenceView()
    }
}
