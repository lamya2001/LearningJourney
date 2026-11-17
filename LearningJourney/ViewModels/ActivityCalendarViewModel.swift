import Observation
import Foundation

@Observable
class ActivityCalendarViewModel {
    let goals: [LearningGoal]
    var now: Date

    init(goals: [LearningGoal], now: Date = Date()) {
        self.goals = goals
        self.now = now
    }

    // MARK: - Months
    var months: [Date] {
        let calendar = Calendar.current
        guard
            let earliest = goals.map(\.startDate).min(),
            let firstMonth = calendar.dateInterval(of: .month, for: earliest)?.start,
            let currentMonth = calendar.dateInterval(of: .month, for: now)?.start,
            let count = calendar.dateComponents([.month], from: firstMonth, to: currentMonth).month,
            count >= 0
        else { return [] }

        return (0...count).compactMap {
            calendar.date(byAdding: .month, value: $0, to: firstMonth)
        }
    }
    
    // MARK: - Days
    func cells(for month: Date) -> [Date?] {
        let calendar = Calendar.current
        guard
            let interval = calendar.dateInterval(of: .month, for: month),
            let dayCount = calendar.range(of: .day, in: .month, for: month)?.count
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7

        let days: [Date?] = (0..<dayCount).compactMap {
            calendar.date(byAdding: .day, value: $0, to: interval.start)
        }
        return Array(repeating: nil, count: leadingBlanks) + days
    }

    func status(on day: Date) -> DayStatus? {
        let calendar = Calendar.current
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: day)) else { return nil }

        let owner = goals
            .filter { $0.startDate < endOfDay }
            .max(by: { $0.startDate < $1.startDate })

        return owner?.log(on: day)?.dayStatus
    }
}
