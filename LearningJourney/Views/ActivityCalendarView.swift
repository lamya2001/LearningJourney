import SwiftUI
import SwiftData

struct ActivityCalendarView: View {
    @Query private var goals: [LearningGoal]
    @State private var viewModel = ActivityCalendarViewModel(goals: [])
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        let model = ActivityCalendarViewModel(goals: goals, now: viewModel.now)

        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(model.months, id: \.self) { month in
                        MonthView(
                            month: month,
                            cells: model.cells(for: month),
                            status: { model.status(on: $0) },
                            today: model.now
                        )
                        .id(month)
                    }
                }
                .padding(.horizontal, 16)
            }
            .onAppear {
                if let last = model.months.last {
                    proxy.scrollTo(last, anchor: .top)
                }
            }
        }
        .navigationTitle("Activities")
        .toolbarTitleDisplayMode(.inline)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { viewModel.now = Date() }
        }
    }
}

#Preview("calendar") {
    let container = try! ModelContainer(
        for: LearningGoal.self, DayLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let calendar = Calendar.current

    func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 20))!
    }

    let goal = LearningGoal(name: "Swift", duration: .year)
    goal.startDate = date(2026, 1, 1)
    container.mainContext.insert(goal)

    // Filled blocks: [start, end] inclusive. Everything outside is empty.
    let filledBlocks: [(from: Date, to: Date)] = [
        (date(2026, 1, 4),  date(2026, 1, 10)),   // one full week
        (date(2026, 1, 25), date(2026, 2, 28)),   // a whole month and more
        (date(2026, 3, 15), date(2026, 3, 21)),   // one week
        (date(2026, 4, 12), date(2026, 5, 16))    // another long stretch
    ]
    // Freeze days inside the blocks.
    let freezeDays: [Date] = [
        date(2026, 1, 8),
        date(2026, 2, 4), date(2026, 2, 18),
        date(2026, 3, 18),
        date(2026, 4, 22), date(2026, 5, 6)
    ]

    var logs: [DayLog] = []
    for block in filledBlocks {
        var current = block.from
        while current <= block.to {
            let isFreeze = freezeDays.contains { calendar.isDate($0, inSameDayAs: current) }
            logs.append(DayLog(dayStatus: isFreeze ? .freeze : .learned, loggedAt: current))
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
    }
    goal.logs = logs

    return NavigationStack {
        ActivityCalendarView()
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}
