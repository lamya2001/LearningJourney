import SwiftUI


struct GoalForm : View {
    @Bindable var goal : LearningGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30){
            
            //goal name
            VStack(alignment: .leading){
                
                Text("I want to learn")
                .font(.callout)
                
                TextField("Swift",text: $goal.name)
                Divider()
            }
            //goal duration
            VStack(alignment: .leading, spacing: 13){
                
                Text("I want to learn it in a")
                    .font(.callout)
                
                HStack(spacing: 12){
                    
                    ForEach(GoalDuration.allCases, id: \.self){ option in
                        
                        if goal.duration == option {
                            Button(option.title){
                                goal.duration = option
                            }.buttonStyle( .glassProminent )
                                .tint(.brandPrimary)
                        }else {
                            Button(option.title){
                                goal.duration = option
                            }.buttonStyle(.glass)
                                .foregroundStyle(.secondary)
                            
                        }
                    }
                }.controlSize(.large)
                 .font(.headline)
            }
            
        }.frame(maxWidth: .infinity ,alignment: .leading)
    }
}

#Preview {
    GoalForm(goal: LearningGoal(name: "", duration: .week))
}

