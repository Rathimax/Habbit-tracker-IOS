import SwiftUI
import Combine

// MARK: - ROW VIEW
struct HabitRowView: View {
    @Bindable var habit: Habit; let stats: UserStats; var onPlus: () -> Void
    @State private var timeRemaining: Int = 0
    @State private var timerActive = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 15) {
                Group { if habit.icon.count > 2 { Image(systemName: habit.icon) } else { Text(habit.icon) } }.font(.system(size: 22)).padding(10).background(habit.themeColor.opacity(0.2)).clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading) {
                    Text(habit.name).font(.headline).bold()
                    if isSkipped(habit) {
                        Text("Skipped Today").font(.caption).foregroundStyle(.orange).italic()
                    } else {
                        Text(habit.isTimerHabit ? (timerActive ? timeString : (timeRemaining == 0 ? "\(habit.timerDurationMinutes)m session" : "Paused: \(timeString)")) : "\(habit.completionCount)/\(habit.goal) today").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                HStack(spacing: 12) {
                    if habit.isTimerHabit && habit.completionCount < habit.goal {
                        Button { timerActive = false; timeRemaining = habit.timerDurationMinutes * 60; SoundManager.instance.playPop() } label: { Image(systemName: "arrow.clockwise.circle").font(.title3).foregroundStyle(.secondary) }.buttonStyle(.plain)
                        Button { if timeRemaining == 0 { timeRemaining = habit.timerDurationMinutes * 60 }; timerActive.toggle(); SoundManager.instance.playPop() } label: { Image(systemName: timerActive ? "pause.circle.fill" : "play.circle.fill").font(.title2).foregroundStyle(habit.themeColor) }.buttonStyle(.plain)
                    } else {
                        Button { if habit.completionCount > 0 { habit.completionCount -= 1; SoundManager.instance.playPop() } } label: { Image(systemName: "minus").font(.caption.bold()).padding(8).background(Color.secondary.opacity(0.1)).clipShape(Circle()) }.buttonStyle(.plain)
                        Button { completeStep() } label: {
                            let done = habit.completionCount >= habit.goal
                            Image(systemName: done ? "checkmark" : "plus").font(.system(size: 16, weight: .bold)).foregroundStyle(.white).padding(10).background(done ? Color.green : habit.themeColor).clipShape(Circle())
                        }.buttonStyle(.plain)
                    }
                }
            }
            ProgressView(value: Double(habit.completionCount), total: Double(habit.goal)).tint(habit.completionCount >= habit.goal ? .green : habit.themeColor)
        }
        .padding().background(ZStack { Color(uiColor: .secondarySystemGroupedBackground); habit.cardGradient }).clipShape(RoundedRectangle(cornerRadius: 22)).shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .onReceive(timer) { _ in if timerActive && timeRemaining > 0 { timeRemaining -= 1; if timeRemaining == 0 { timerActive = false; habit.timedSessionsCompleted += 1; completeStep(); SoundManager.instance.playSuccess() } } }
    }
    var timeString: String { String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60) }
    func completeStep() {
        if habit.completionCount < habit.goal {
            habit.completionCount += 1; SoundManager.instance.playPop()
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; let today = f.string(from: Date())
            habit.completionHistory[today, default: 0] += 1
            if habit.completionCount == habit.goal && habit.lastXPDate != today { stats.totalXP += 10; habit.totalCompletionsEver += 1; habit.lastXPDate = today }
            onPlus()
        }
    }

    func isSkipped(_ h: Habit) -> Bool {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; let today = f.string(from: Date())
        return h.skippedDays.contains(today)
    }
}
