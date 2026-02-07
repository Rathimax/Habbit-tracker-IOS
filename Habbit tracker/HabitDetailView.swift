import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    private var days: [CalDay] {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return (0..<35).map { i in let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!; return CalDay(isCompleted: (habit.completionHistory[f.string(from: date)] ?? 0) >= habit.goal, themeColor: habit.themeColor) }
    }
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Group { if habit.icon.count > 2 { Image(systemName: habit.icon).font(.system(size: 80)) } else { Text(habit.icon).font(.system(size: 80)) } }.padding(20).background(habit.themeColor.opacity(0.15)).clipShape(Circle())
                Text(habit.name).font(.largeTitle.bold())
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) { ForEach(days) { day in Circle().fill(day.isCompleted ? day.themeColor : Color.secondary.opacity(0.1)).frame(width: 30, height: 30).overlay(day.isCompleted ? Image(systemName: "checkmark").font(.caption2).bold().foregroundStyle(.white) : nil) } }.padding().background(Color(uiColor: .secondarySystemGroupedBackground)).clipShape(RoundedRectangle(cornerRadius: 20)).padding(.horizontal)
            }
        }.navigationTitle("History").navigationBarTitleDisplayMode(.inline)
    }
}
