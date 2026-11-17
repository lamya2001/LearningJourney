import SwiftUI
import SwiftData

struct GoalEditorView: View {
    @State private var viewModel = GoalEditorViewModel()
    @State private var showsAlert = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let editing: LearningGoal?
    
    var body: some View {
        VStack{
            GoalForm(goal: viewModel.draft)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 36)
        .navigationTitle("Learning Goal")
        .onAppear {
            viewModel.prepare(editing: editing)
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    confirm()
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                }
                .buttonStyle(.glassProminent)
                .tint(.brandPrimary)
                .disabled(!viewModel.canSave)
            }
        }
        .alert("Update goal", isPresented: $showsAlert) {
            Button("Dismiss", role: .cancel) { }
            Button("Update") { save() }
        } message: {
            Text("If you update now, your streak will start over.")
        }
    }

    private func confirm() {
        if editing != nil {
            showsAlert = true
        } else {
            save()
        }
    }

    private func save() {
        viewModel.save(context: modelContext)
        dismiss()
    }
}

#Preview("Editing") {
    NavigationStack {
        GoalEditorView(editing: LearningGoal(name: "Swift", duration: .month))
    }
    .modelContainer(for: [LearningGoal.self, DayLog.self], inMemory: true)
    .preferredColorScheme(.dark)
}
