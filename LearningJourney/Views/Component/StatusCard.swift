import SwiftUI

struct StatCard: View {
    let icon: String
    let tint: Color
    let value: Int
    let label: String
    
    var unit: String {
        value == 1 ? "day" : "days"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2.bold())
                .foregroundStyle(tint)
            
            VStack(alignment: .center,spacing: 4){
                Text("\(value) \(unit)")
                    .font(.callout.weight(.semibold))
                Text(label)
                    .font(.caption)
            }

        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .glassEffect(.clear, in: .rect(cornerRadius: 34))
    }
}


#Preview {
    HStack{
        StatCard(icon: "flame.fill", tint: .brandPrimary, value: 2, label: "Learned")
        StatCard(icon: "snowflake", tint: .freeze, value: 2, label: "Freezed")
    }
}
