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

#Preview("Fixed dates") {
    let container = try! ModelContainer(
        for: LearningGoal.self, DayLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let calendar = Calendar.current

    func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 9))!
    }

    let goal = LearningGoal(name: "Swift", duration: .year)
    goal.startDate = date(2026, 1, 1)
    container.mainContext.insert(goal)

    goal.logs = [
        DayLog(dayStatus: .learned, loggedAt: date(2026, 1, 1)),
        DayLog(dayStatus: .learned, loggedAt: date(2026, 1, 15)),
        DayLog(dayStatus: .freeze,  loggedAt: date(2026, 1, 20)),
        DayLog(dayStatus: .learned, loggedAt: date(2026, 1, 31)),
        DayLog(dayStatus: .learned, loggedAt: date(2026, 2, 1)),
        DayLog(dayStatus: .freeze,  loggedAt: date(2026, 2, 14)),
        DayLog(dayStatus: .learned, loggedAt: date(2026, 2, 28)),
        DayLog(dayStatus: .learned, loggedAt: date(2026, 3, 1))
    ]

    return NavigationStack {
        ActivityCalendarView()
    }
    .modelContainer(container)
    .preferredColorScheme(.light)
}
