import Foundation

extension Date {
    static func dateString(from dateString: String, format: String = APIConstants.dateFormat) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: dateString)
    }

    func toString(format: String = APIConstants.dateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
