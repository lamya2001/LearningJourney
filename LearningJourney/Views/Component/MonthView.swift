import SwiftUI

struct MonthView: View {
    let month: Date
    let cells: [Date?]
    let status: (Date) -> DayStatus?
    let today: Date

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(month, format: .dateTime.month(.wide).year())
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Calendar.current.shortStandaloneWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol.uppercased())
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        DayCell(
                            day: Calendar.current.component(.day, from: day),
                            status: status(day),
                            isToday: Calendar.current.isDate(day, inSameDayAs: today)
                        )
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
    }
}
