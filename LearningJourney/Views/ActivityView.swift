import SwiftUI
import SwiftData

struct ActivityView : View {
    @State private var viewModel: ActivityViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var showsEditor = false
    @State private var showsCalendar = false
    
    init(goal: LearningGoal) {
        _viewModel = State(initialValue: ActivityViewModel(goal: goal))
    }
    
    var logButtonTextColor: Color {
        viewModel.canLogToday ? .white : .primary
    }
    
    var body: some View {
        NavigationStack{
            
            VStack(spacing: 0){
                VStack(spacing: 12){
                    
                    Text(viewModel.now, format: .dateTime.weekday(.wide).day().month(.wide))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        ForEach(viewModel.weekDays, id: \.self) { day in
                            VStack(spacing: 6) {
                                Text(day, format: .dateTime.weekday(.narrow))
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.primary)
                                
                                DayCell(
                                    day: Calendar.current.component(.day, from: day),
                                    status: viewModel.status(on: day),
                                    isToday: Calendar.current.isDate(day, inSameDayAs: viewModel.now)
                                )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        StatCard(icon: "flame.fill", tint: .brandPrimary, value: viewModel.currentStreak, label: "Learned")
                        StatCard(icon: "snowflake", tint: .freeze, value: viewModel.freezeCount, label: "Freezed")
                    }
                }
                switch viewModel.progress {
                case .active:
                    Spacer()
                    
                    Button{
                        viewModel.logLearned(context : modelContext)
                    } label: {
                        Text(viewModel.canLogToday ? "Log as Learned" : "Logged as Learned")                        .font(.body.bold())
                            .foregroundStyle(logButtonTextColor)
                            .frame(width: 272, height: 272)
                        
                    }.buttonStyle(.plain)
                        .glassEffect(.regular.tint(viewModel.canLogToday ? .brandPrimary : .clear).interactive(), in: .circle)
                        .disabled(!viewModel.canLogToday)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        
                        Button {
                            viewModel.logFreeze(context: modelContext)
                        } label: {
                            Text("Freeze for a day")
                                .frame(width: 230)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(.freeze)
                        .controlSize(.large)
                        .disabled(!viewModel.canFreezeToday)
                        
                        Text(viewModel.freezeUsageText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                case .succeeded, .failed:
                    Spacer()
                    
                    GoalCompleted(progress: viewModel.progress) {
                        showsEditor = true
                    }
                    
                    Spacer()
                }
                
            }.padding(.horizontal, 16)
                .navigationDestination(isPresented: $showsEditor) {
                    GoalEditorView(editing: viewModel.progress == .active ? viewModel.goal : nil)
                }
                .navigationDestination(isPresented: $showsCalendar) {
                    ActivityCalendarView()
                }
                .navigationTitle("Activity")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showsCalendar = true
                        } label: {
                            Image(systemName: "calendar")
                        }
                    }
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showsEditor = true
                        } label: {
                            Image(systemName: "pencil.and.outline")
                        }
                    }
                }
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                viewModel.refresh()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    viewModel.refresh()
                }
            }
    }
}


#Preview("Succeeded") {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: -offset, to: today)!
            .addingTimeInterval(20 * 3600)
    }

    let goal = LearningGoal(name: "Swift", duration: .week)
    goal.startDate = calendar.date(byAdding: .day, value: -7, to: today)!
    goal.logs = [
        DayLog(dayStatus: .learned, loggedAt: day(7)),
        DayLog(dayStatus: .learned, loggedAt: day(6)),
        DayLog(dayStatus: .freeze,  loggedAt: day(5)),
        DayLog(dayStatus: .learned, loggedAt: day(4)),
        DayLog(dayStatus: .learned, loggedAt: day(3)),
        DayLog(dayStatus: .freeze,  loggedAt: day(2)),
        DayLog(dayStatus: .learned, loggedAt: day(1))
    ]

    return ActivityView(goal: goal)
        .preferredColorScheme(.dark)
}
#Preview("activity") {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: -offset, to: today)!
            .addingTimeInterval(20 * 3600)
    }

    let goal = LearningGoal(name: "Swift", duration: .week)
    goal.startDate = calendar.date(byAdding: .day, value: -6, to: today)!
    goal.logs = [
       // DayLog(dayStatus: .learned, loggedAt: day(7)),
        DayLog(dayStatus: .learned, loggedAt: day(6)),
        DayLog(dayStatus: .learned,  loggedAt: day(5)),
        DayLog(dayStatus: .learned, loggedAt: day(4)),
        DayLog(dayStatus: .learned, loggedAt: day(3)),
        DayLog(dayStatus: .freeze,  loggedAt: day(2)),
        DayLog(dayStatus: .learned, loggedAt: day(1))
    ]

    return ActivityView(goal: goal)
        .preferredColorScheme(.dark)
}
#Preview("Failed") {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: -offset, to: today)!
            .addingTimeInterval(20 * 3600)
    }

    let goal = LearningGoal(name: "Swift", duration: .week)
    goal.startDate = calendar.date(byAdding: .day, value: -7, to: today)!
    goal.logs = [
        DayLog(dayStatus: .learned, loggedAt: day(7)),
        DayLog(dayStatus: .learned, loggedAt: day(6)),
        DayLog(dayStatus: .freeze,  loggedAt: day(5)),
        DayLog(dayStatus: .learned, loggedAt: day(4)),
        // day(3) is missing on purpose
        DayLog(dayStatus: .freeze,  loggedAt: day(2)),
        DayLog(dayStatus: .learned, loggedAt: day(1))
    ]

    return ActivityView(goal: goal)
        .preferredColorScheme(.dark)
}
