import SwiftUI
import SwiftData

struct OnboardingView : View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        
        VStack(spacing: 37){
            // MARK: - Top
            VStack(spacing:80){
                //icon
                Image(systemName: "flame.fill")
                    .foregroundStyle(.brandPrimary)
                    .font(.largeTitle .bold())
                //text
                VStack(alignment: .leading){
                    Text("\(Text("Hello")) \(Text("Learner").bold())")
                        .font(.largeTitle)
                        
                    Text("This app will help you learn everyday!")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // MARK: - Mid
            VStack(alignment: .leading, spacing: 30){
                
                GoalForm(goal: viewModel.goal)
                
            }.frame(maxWidth: .infinity ,alignment: .leading)
            
            Spacer()
            
            // MARK: - Bottom
            VStack(spacing: 12){
                
                Button("Start Learning"){
                    viewModel.start(context : modelContext)
                }.buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .font(.headline)
                    .tint(.brandPrimary)
                    .disabled(!viewModel.canStart)
                
                Text("You can edit your desire later")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }.padding(.horizontal,16)
         .padding(.top, 68)
         //.preferredColorScheme(.dark)
    }
}

#Preview {
    OnboardingView()
}
