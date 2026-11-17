import SwiftUI

struct DayCell : View {
    let day : Int
    let status : DayStatus?
    let isToday: Bool
    
    var isTodayWithoutLog: Bool {
        isToday && status == nil
    }
    
    var color : Color{
        if isTodayWithoutLog { return .white}
        switch status {
        case .learned: return .brandPrimary
        case .freeze: return .freeze
        case nil: return .primary
        }
    }
    
    var backgroundColor : Color{
        if isTodayWithoutLog { return .brandPrimary}
        switch status {
        case .learned: return .brandPrimary.opacity(0.12)
        case .freeze: return .freeze.opacity(0.12)
        case nil: return .clear
        }
    }
    
    var body: some View {
       Text("\(day)")
            .foregroundStyle(color)
            .font(.title3.weight(isTodayWithoutLog ? .bold : .regular))
            .frame(width: 44, height: 44)
            .background(backgroundColor, in: Circle())
    }
}

#Preview {
    DayCell(day: 24, status: nil , isToday: false )
}
