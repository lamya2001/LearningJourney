import Testing
import Foundation
import SwiftData
@testable import LearningJourney

struct StreakTests {

    @Test func twoLearnedDaysGiveStreakOfTwo() {
        let hour: TimeInterval = 3600
        let start = Date(timeIntervalSince1970: 0)

        let goal = LearningGoal(name: "Swift", duration: .week)
        goal.startDate = start
        goal.logs = [
            DayLog(dayStatus: .learned, loggedAt: start + 1 * hour),
            DayLog(dayStatus: .learned, loggedAt: start + 25 * hour)
        ]

        let viewModel = ActivityViewModel(goal: goal)
        let result = viewModel.streak(now: start + 27 * hour)

        #expect(result == 2)
    }
    
    @Test func streakResetsAfter32Hours() {
        let hour: TimeInterval = 3600
        let start = Date(timeIntervalSince1970: 0)

        let goal = LearningGoal(name: "Swift", duration: .week)
        goal.startDate = start
        goal.logs = [
            DayLog(dayStatus: .learned, loggedAt: start + 1 * hour)
        ]

        let viewModel = ActivityViewModel(goal: goal)
        let result = viewModel.streak(now: start + 49 * hour)

        #expect(result == 0)
    }
    
    @Test func freezeKeepsStreakAlive() {
        let hour: TimeInterval = 3600
        let start = Date(timeIntervalSince1970: 0)

        let goal = LearningGoal(name: "Swift", duration: .week)
        goal.startDate = start
        goal.logs = [
            DayLog(dayStatus: .learned, loggedAt: start + 1 * hour),
            DayLog(dayStatus: .freeze, loggedAt: start + 25 * hour)
        ]

        let viewModel = ActivityViewModel(goal: goal)
        let result = viewModel.streak(now: start + 49 * hour)

        #expect(result == 1)
    }

    @Test func freezeDoesNotIncreaseStreak() {
        let hour: TimeInterval = 3600
        let start = Date(timeIntervalSince1970: 0)

        let goal = LearningGoal(name: "Swift", duration: .week)
        goal.startDate = start
        goal.logs = [
            DayLog(dayStatus: .learned, loggedAt: start + 1 * hour),
            DayLog(dayStatus: .freeze, loggedAt: start + 25 * hour)
        ]

        let viewModel = ActivityViewModel(goal: goal)
        let result = viewModel.streak(now: start + 27 * hour)

        #expect(result == 1)
    }
    
    @Test func canLogAgainAfterMidnight() {
        let calendar = Calendar.current
        let night = calendar.date(from: DateComponents(year: 2026, month: 11, day: 16, hour: 23, minute: 0))!
        let nextDay = calendar.date(from: DateComponents(year: 2026, month: 11, day: 17, hour: 0, minute: 30))!

        let goal = LearningGoal(name: "Swift", duration: .week)
        goal.startDate = night.addingTimeInterval(-3600)
        goal.logs = [DayLog(dayStatus: .learned, loggedAt: night)]

        let viewModel = ActivityViewModel(goal: goal)

        viewModel.now = night.addingTimeInterval(60)
        #expect(viewModel.canLogToday == false)

        viewModel.now = nextDay
        #expect(viewModel.canLogToday == true)
    }
    
    @Test func freezeThenLearnedKeepsOneLog() throws {
        let container = try ModelContainer(
            for: LearningGoal.self, DayLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)

        let goal = LearningGoal(name: "Swift", duration: .week)
        context.insert(goal)
        let viewModel = ActivityViewModel(goal: goal)

        viewModel.logFreeze(context: context)
        #expect(goal.logs.count == 1)
        #expect(goal.usedFreezes == 1)

        viewModel.logLearned(context: context)
        #expect(goal.logs.count == 1)
        #expect(goal.logs.first?.dayStatus == .learned)
        #expect(goal.usedFreezes == 0)
    }
    
    @Test func goalSucceedsWhenEveryDayIsLogged() {
        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: 15))!

        let goal = LearningGoal(name: "Swift", duration: .week)
        goal.startDate = start
        goal.logs = (0..<7).map { i in
            DayLog(dayStatus: i < 2 ? .freeze : .learned,
                   loggedAt: calendar.date(byAdding: .day, value: i, to: start)!)
        }

        let viewModel = ActivityViewModel(goal: goal)
        viewModel.now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 8, hour: 10))!

        #expect(viewModel.progress == .succeeded)
    }

    @Test func goalFailsWhenADayIsMissing() {
        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: 15))!

        let goal = LearningGoal(name: "Swift", duration: .week)
        goal.startDate = start
        goal.logs = (0..<7).filter { $0 != 3 }.map { i in
            DayLog(dayStatus: .learned,
                   loggedAt: calendar.date(byAdding: .day, value: i, to: start)!)
        }

        let viewModel = ActivityViewModel(goal: goal)
        viewModel.now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 8, hour: 10))!

        #expect(viewModel.progress == .failed)
    }

    @Test func goalIsActiveBeforeItsEnd() {
        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: 15))!

        let goal = LearningGoal(name: "Swift", duration: .week)
        goal.startDate = start

        let viewModel = ActivityViewModel(goal: goal)
        viewModel.now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 7, hour: 23))!

        #expect(viewModel.progress == .active)
    }
    
    @Test func cannotLogOrFreezeAfterGoalEnds() {
        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: 15))!

        let goal = LearningGoal(name: "Swift", duration: .week)
        goal.startDate = start
        let viewModel = ActivityViewModel(goal: goal)

        viewModel.now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 7, hour: 23))!
        #expect(viewModel.canLogToday == true)
        #expect(viewModel.canFreezeToday == true)

        viewModel.now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 8, hour: 10))!
        #expect(viewModel.canLogToday == false)
        #expect(viewModel.canFreezeToday == false)
    }
    
    @Test func prepareFillsDraftFromCurrentGoalOrStartsEmpty() {
        let editor = GoalEditorViewModel()
        let goal = LearningGoal(name: "Swift", duration: .month)

        editor.prepare(editing: goal)
        #expect(editor.draft.name == "Swift")
        #expect(editor.draft.duration == .month)
        #expect(editor.draft !== goal)

        editor.draft.name = "changed"
        editor.prepare(editing: nil)
        #expect(editor.draft.name == "")
        #expect(editor.draft.duration == .week)
        #expect(goal.name == "Swift")
    }

    
    
}
