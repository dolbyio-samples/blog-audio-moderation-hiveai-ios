import SwiftUI

struct ConferenceView: View {

    @State var conferenceName: String = ""
    @State var userName: String = ""

    // The Model that uses the Dolby.io Comms SDK
    @StateObject var conference = Conference()
    // The AudioRecorder that records the last 10 seconds
    @StateObject var audioRecorder = AudioRecorder()
    // The Model that uploads an audio file to Thehive.ai
    @StateObject var audioModeration = AudioModeration()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Image("dolbyioLogo")
            }
            .frame(height: 190)
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
                Button("Request Audio Moderation") {
                    audioModeration.post(from: audioRecorder)
                }
                .buttonStyle(.plain)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 250, height: 50)
                .background(Color.accent)
                .cornerRadius(5.0)
                .disabled(audioModeration.isLoading)
                Text(audioModeration.errorMessage)
                    .foregroundColor(.red)
                VStack {
                    if let status = audioModeration.resultStatus {
                        Text("Moderation Result")
                            .font(.title2)
                        Divider()
                        VStack(alignment: .leading) {
                            Text("Code: \(status.code)")
                            Text("Message: \(status.message)")
                            Text("Language: \(status.language)")
                            Divider()
                        }
                        Text("Transcribed Text:")
                            .font(.headline)
                        Text(audioModeration.transcript)
                        Divider()
                        Text("Classifications:")
                            .font(.headline)
                        ForEach(audioModeration.classifications, id: \.id) { result in
                            if let text = result.text, let classes = result.classes {
                                VStack(alignment: .leading) {
                                    Divider()
                                        .padding(.bottom)
                                    Text("Text:")
                                        .font(.headline)
                                    Text(text)
                                    Text("Classes:")
                                        .font(.headline)
                                    ForEach(classes, id: \.id) { item in
                                        Text("\(item.class): \(item.score)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(.background)
            .cornerRadius(20)
        }
        .background(
            LinearGradient(
                colors: [.accent, .accentLight],
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea()
        )
    }
}

struct ConferenceView_Previews: PreviewProvider {
    static var previews: some View {
        ConferenceView()
    }
}
