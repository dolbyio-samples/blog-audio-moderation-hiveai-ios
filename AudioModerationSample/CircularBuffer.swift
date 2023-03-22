import Foundation

final class CircularBuffer {

    private let accessQueue = DispatchQueue(label: "io.dolby.sample.circular-buffer")

    private var array: [Data?]
    private var currentIndex: Int = 0

    init(size: Int) {
        array = [Data?](repeating: nil, count: size)
    }

    public func write(_ data: Data) {
        accessQueue.async { [weak self] in
            guard let self = self else { return }

            self.array[self.currentIndex % self.array.count] = data
            self.currentIndex += 1
        }
    }

    public func readAll() -> Data {
        var allData = Data()
        accessQueue.sync(flags: .barrier) {
            for index in 0..<self.array.count {
                if let data = self.array[(index + self.currentIndex) % self.array.count] {
                    allData.append(data)
                }
            }
        }
        return allData
    }

    public func clear() {
        accessQueue.async { [weak self] in
            guard let self = self else { return }

            for i in 0..<self.array.count {
                self.array[i] = nil
            }
            self.currentIndex = 0
        }
    }
}

