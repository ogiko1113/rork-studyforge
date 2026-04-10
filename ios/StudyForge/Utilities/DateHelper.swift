import Foundation

nonisolated enum DateHelper {
    static func nowMillis() -> Double {
        Date().timeIntervalSince1970 * 1000
    }

    static func startOfDayMillis(for date: Date = Date()) -> Double {
        Calendar.current.startOfDay(for: date).timeIntervalSince1970 * 1000
    }

    static func dateFromMillis(_ millis: Double) -> Date {
        Date(timeIntervalSince1970: millis / 1000)
    }

    static func isSameDay(_ millis: Double, as date: Date = Date()) -> Bool {
        Calendar.current.isDate(dateFromMillis(millis), inSameDayAs: date)
    }

    static func formatRelativeDay(_ interval: Double) -> String {
        let days = Int(interval)
        if days == 0 { return "今すぐ" }
        if days == 1 { return "1日後" }
        if days < 30 { return "\(days)日後" }
        if days < 365 {
            let months = days / 30
            return "\(months)ヶ月後"
        }
        let years = days / 365
        return "\(years)年後"
    }

    static func formatDateTime(_ millis: Double) -> String {
        let date = dateFromMillis(millis)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date()
    }
}
