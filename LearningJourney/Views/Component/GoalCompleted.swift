import SwiftUI

struct GoalCompleted: View {
    let progress: GoalProgress
    let onSetGoal: () -> Void

    private var isSuccess: Bool {
        progress == .succeeded
    }

    private var icon: String {
        isSuccess ? "hands.and.sparkles.fill" : "xmark.seal"
    }

    private var title: String {
        isSuccess ? "Well done!" : "You didn't reach your goal this time."
    }

    private var subtitle: String {
        isSuccess ? "Ready for your next goal?" : "Want to set another goal?"
    }

    var body: some View {
        VStack(spacing: 64) {
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(.brandPrimary)
                VStack(spacing: 0){
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                onSetGoal()
            } label: {
                Label("Set a goal", systemImage: "pencil.and.outline")
            }
            .buttonStyle(.glassProminent)
            .tint(.brandPrimary)
            .controlSize(.large)
        }
    }
}

#Preview {
    VStack(spacing: 60) {
        GoalCompleted(progress: .succeeded, onSetGoal: {})
        GoalCompleted(progress: .failed, onSetGoal: {})
    }
    .preferredColorScheme(.dark)
}
