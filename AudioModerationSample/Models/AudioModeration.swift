import Foundation
import UniformTypeIdentifiers

final class AudioModeration: ObservableObject {

    @Published private(set) var transcript: String = "-"
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var classifications: [AudioModerationClassification] =  []
    @Published private(set) var resultStatus: ResultStatus?
    @Published private(set) var errorMessage: String = ""

    private let urlSession: URLSession
    private let hiveSyncTaskUrl = URL(string: "https://api.thehive.ai/api/v2/task/sync")
    private var sessionTask: URLSessionUploadTask?

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func post(from audioRecorder: AudioRecorder) {
        isLoading = true
        DispatchQueue(label: "Audio Moderation Queue", qos: .background).async { [weak self] in
            guard let self = self else { return }

            do {
                let fileURL = try audioRecorder.getBufferedAudioFileUrl()
                try self.uploadFile(from: fileURL)
            } catch {
                self.handle(error: error.localizedDescription)
            }
        }
    }

    private func uploadFile(from fileURL: URL) throws {
        guard let postURL = self.hiveSyncTaskUrl else { return }
        // generate boundary string using a unique string
        let boundary = UUID().uuidString

        let fileName = fileURL.lastPathComponent
        let mimetype = self.mimeType(for: fileName)
        let paramName = "media"
        let fileData = try Data(contentsOf: fileURL)

        // Set the URLRequest to POST and to the specified URL
        var request = URLRequest(url: postURL)
        request.httpMethod = "POST"
        request.addValue("Token \(Configuration.hiveProjectApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        // Add the file data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append(
            "Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n"
                .data(using: .utf8)!
        )
        data.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.setValue(String(data.count), forHTTPHeaderField: "Content-Length")

        self.sessionTask = self.urlSession.uploadTask(with: request, from: data) { data, response, error in
            guard error == nil,
                  let data = data,
                  (response as? HTTPURLResponse)?.statusCode == 200
            else {
                if let error = error {
                    self.handle(error: error.localizedDescription)
                } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    self.handle(error: "HTTP status code \(statusCode)")
                } else {
                    self.handle(error: "Unknown error")
                }
                return
            }

            let result = try? JSONDecoder().decode(AudioModerationResult.self, from: data)
            DispatchQueue.main.async { [weak self] in
                if let status = result?.status?.first {
                    self?.resultStatus = ResultStatus(
                        code: status.status.code,
                        message: status.status.message,
                        language: status.response?.language ?? ""
                    )
                    let output = status.response?.output?.first
                    self?.transcript = output?.transcript ?? "empty"
                    self?.classifications = output?.classifications ?? .init()
                    self?.isLoading = false
                } else {
                    self?.handle(error: "JSON decode error")
                }
            }
        }

        self.sessionTask?.resume()
    }

    private func handle(result: AudioModerationResult?) {
        DispatchQueue.main.async { [weak self] in
            if let status = result?.status?.first {
                self?.errorMessage = ""
                self?.resultStatus = ResultStatus(
                    code: status.status.code,
                    message: status.status.message,
                    language: status.response?.language ?? ""
                )
                let output = status.response?.output?.first
                self?.transcript = output?.transcript ?? "empty"
                self?.classifications = output?.classifications ?? .init()
                self?.isLoading = false
            } else {
                self?.handle(error: "JSON decode error")
            }
        }
    }

    private func mimeType(for path: String) -> String {
        return UTType(
            tag: URL(fileURLWithPath: path).pathExtension,
            tagClass: .filenameExtension,
            conformingTo: nil
        )?.preferredMIMEType ?? "application/octet-stream"
    }

    private func handle(error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.resultStatus = nil
            self?.transcript = "-"
            self?.classifications = []
            self?.isLoading = false
            self?.errorMessage = error
        }
    }
}

struct ResultStatus {
    let code: String
    let message: String
    let language: String
}

// MARK: - thehive.ai response DTOs
struct AudioModerationResult: Codable {
    let status: [AudioModerationStatus]?
}

struct AudioModerationStatus: Codable {
    let status: AudioModerationResponseStatus
    let response: AudioModerationResponse?
}

struct AudioModerationResponseStatus: Codable {
    let code: String
    let message: String
}

struct AudioModerationResponse: Codable {
    let output: [AudioModerationOutput]?
    let language: String
}

struct AudioModerationOutput: Codable {
    let transcript: String?
    let classifications: [AudioModerationClassification]?
}

struct AudioModerationClassification: Codable, Identifiable {
    let id = UUID()

    let classes: [AudioModerationClass]?
    let text: String?
}

struct AudioModerationClass: Codable, Identifiable {
    let id = UUID()

    let `class`: String
    let score: Double
}
