import Foundation
import VoxeetSDK

final class AudioRecorder: ObservableObject {

    @Published private(set) var isRecording: Bool = false

    private let bitsPerByte = 8
    private let dataByteSize: Int = 2

    private var channelCount: Int = 1 {
        willSet(newValue) {
            if newValue != channelCount {
                audioBuffer?.clear()
            }
        }
    }
    private var sampleRate: Int = 0 {
        willSet(newSampleRate) {
            if newSampleRate != sampleRate {
                audioBuffer?.clear()
            }
        }
    }

    private var audioBuffer: CircularBuffer?

    func start() {
        VoxeetSDK.shared.audio.local.delegate = self
        isRecording = true
    }

    func stop() {
        VoxeetSDK.shared.audio.local.delegate = nil
        isRecording = false
    }

    func getBufferedAudioFileUrl() throws -> URL {

        guard let pcmData = audioBuffer?.readAll(), !pcmData.isEmpty else {
            throw AudioRecorderError.corruptedAudioData
        }

        let documentDirectoryUrl = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let wavFileUrl = documentDirectoryUrl.appendingPathComponent("input_audio.wav")
        guard createWAV(from: pcmData, to: wavFileUrl.path) else {
            throw AudioRecorderError.corruptedAudioData
        }

        return wavFileUrl
    }

    private func createWAV(from pcmData: Data, to wavFilePath: String) -> Bool {
        // Make sure that the path does not contain non-ascii characters
        guard let fout = fopen(wavFilePath.cString(using: .ascii), "w") else { return false }

        var numChannels: CShort = CShort(channelCount)
        let numChannelsInt: CInt = CInt(channelCount)
        var bitsPerSample: CShort = CShort(dataByteSize * bitsPerByte)
        let bitsPerSampleInt: CInt = CInt(dataByteSize * bitsPerByte)
        var samplingRate: CInt = CInt(sampleRate)
        let numOfSamples = CInt(pcmData.count)
        var byteRate = numChannelsInt * bitsPerSampleInt * samplingRate / 8
        var blockAlign = numChannelsInt * bitsPerSampleInt / 8
        var dataSize = numChannelsInt * numOfSamples * bitsPerSampleInt / 8
        var chunkSize: CInt = 16
        var totalSize = 46 + dataSize
        var audioFormat: CShort = 1

        fwrite("RIFF".cString(using: .ascii), MemoryLayout<CChar>.size, 4, fout)
        fwrite(&totalSize, MemoryLayout<CInt>.size, 1, fout)
        fwrite("WAVE".cString(using: .ascii), MemoryLayout<CChar>.size, 4, fout);
        fwrite("fmt ".cString(using: .ascii), MemoryLayout<CChar>.size, 4, fout);
        fwrite(&chunkSize, MemoryLayout<CInt>.size,1,fout);
        fwrite(&audioFormat, MemoryLayout<CShort>.size, 1, fout);
        fwrite(&numChannels, MemoryLayout<CShort>.size,1,fout);
        fwrite(&samplingRate, MemoryLayout<CInt>.size, 1, fout);
        fwrite(&byteRate, MemoryLayout<CInt>.size, 1, fout);
        fwrite(&blockAlign, MemoryLayout<CShort>.size, 1, fout);
        fwrite(&bitsPerSample, MemoryLayout<CShort>.size, 1, fout);
        fwrite("data".cString(using: .ascii), MemoryLayout<CChar>.size, 4, fout);
        fwrite(&dataSize, MemoryLayout<CInt>.size, 1, fout);
        fclose(fout);

        guard let handle = FileHandle(forUpdatingAtPath: wavFilePath) else { return false }

        handle.seekToEndOfFile()
        handle.write(pcmData)
        handle.closeFile()

        return true
    }
}

// MARK: - SDK AudioDelegate
extension AudioRecorder : AudioDelegate {

    func audioRecordSamplesReady(samples: AudioSamples) {
        guard let audioBufferList = UnsafeMutableAudioBufferListPointer(samples.bufferList) else { return }
        sampleRate = Int(samples.sampleRate)
        for buffer in audioBufferList {
            channelCount = Int(buffer.mNumberChannels)
            let bufferByteSize = Int(buffer.mDataByteSize)
            let data = Data(bytes: buffer.mData!, count: bufferByteSize)
            if audioBuffer == nil {
                // 10 seconds buffer
                let bufforSize = (sampleRate / (bufferByteSize / dataByteSize)) * 10
                audioBuffer = CircularBuffer(size: bufforSize)
            }
            audioBuffer?.write(data)
        }
    }
}

enum AudioRecorderError : Error {
    case corruptedAudioData
}

extension AudioRecorderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .corruptedAudioData:
            return NSLocalizedString(
                "Audio data is corrupted",
                comment: "Check the conversion method from PCM to WAV."
            )
        }
    }
}
