import Foundation

extension UserDefaults {

    static let standard = UserDefaults.standard
    static let kConferenceNameKey = "kConferenceNameKey"
    static let kUserNameKey = "kUserNameKey"

    static var conferenceName: String? {
        get { standard.string(forKey: kConferenceNameKey) }
        set { standard.set(newValue, forKey: kConferenceNameKey) }
    }

    static var userName: String? {
        get { standard.string(forKey: kUserNameKey) }
        set { standard.set(newValue, forKey: kUserNameKey) }
    }
}
