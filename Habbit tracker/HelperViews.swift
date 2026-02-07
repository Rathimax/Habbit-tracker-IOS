import SwiftUI

// MARK: - HELPER TYPES & VIEWS
struct HeatSquare: Identifiable { let id = UUID(); let opacity: Double }
struct CalDay: Identifiable { let id = UUID(); let isCompleted: Bool; let themeColor: Color }
struct Particle: Identifiable { let id = UUID(); let color: Color; let x: CGFloat; let y: CGFloat; let delay: Double }
struct Badge: Identifiable { let id = UUID(); let name: String; let icon: String; let description: String }

struct DashboardCard: View {
    let stats: UserStats
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 15) {
                VStack(alignment: .leading) { Text("Level \(stats.currentLevel)").font(.title2.bold()); Text("\(stats.xpInLevel)/100 XP").font(.caption).foregroundStyle(.secondary) }
                Spacer(); HStack(spacing: 4) { Text("🔥"); Text("\(stats.globalStreak)").bold() }.padding(.horizontal, 12).padding(.vertical, 6).background(Color.orange.opacity(0.15)).clipShape(Capsule())
            }
            ProgressView(value: Double(stats.xpInLevel), total: 100).tint(.purple)
        }.padding().background(Color(uiColor: .secondarySystemGroupedBackground)).clipShape(RoundedRectangle(cornerRadius: 22)).shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

struct HeatmapView: View {
    let habits: [Habit]; let rows = Array(repeating: GridItem(.fixed(12), spacing: 4), count: 7)
    private var squares: [HeatSquare] {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return (0..<84).map { i in let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!; return HeatSquare(opacity: Double(habits.reduce(0) { $0 + ($1.completionHistory[f.string(from: date)] ?? 0) }) * 0.25) }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Activity Map").font(.headline)
            ScrollView(.horizontal, showsIndicators: false) { LazyHGrid(rows: rows, spacing: 4) { ForEach(squares) { square in RoundedRectangle(cornerRadius: 3).fill(square.opacity > 0 ? Color.green.opacity(square.opacity) : Color.secondary.opacity(0.1)).frame(width: 12, height: 12) } }.rotationEffect(.degrees(180)).scaleEffect(x: -1, y: 1, anchor: .center) }
        }.padding().background(Color(uiColor: .secondarySystemGroupedBackground)).clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct SymbolPicker: View {
    @Binding var selectedSymbol: String
    let symbols = ["figure.run", "heart.fill", "book.fill", "cup.and.saucer.fill", "brain.head.profile", "dumbbell.fill", "bed.double.fill", "leaf.fill", "pencil", "clock.fill", "laptopcomputer", "star.fill"]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 15) { ForEach(symbols, id: \.self) { s in Image(systemName: s).font(.title2).padding(10).background(selectedSymbol == s ? Color.blue.opacity(0.3) : Color.secondary.opacity(0.2)).clipShape(Circle()).onTapGesture { selectedSymbol = s } } }.padding(.vertical, 5) }
    }
}

struct QuoteView: View {
    var body: some View { Text("Focus on the process.").font(.system(.subheadline, design: .serif)).italic().foregroundStyle(.secondary).frame(maxWidth: .infinity).padding(.vertical, 10) }
}

struct ConfettiView: View {
    @State private var animate = false
    private let particles: [Particle] = (0..<40).map { i in Particle(color: [.blue, .red, .green, .yellow, .pink, .orange].randomElement()!, x: .random(in: -150...150), y: .random(in: -400...100), delay: Double(i) * 0.02) }
    var body: some View { ZStack { ForEach(particles) { p in Circle().fill(p.color).frame(width: 8).offset(x: animate ? p.x : 0, y: animate ? p.y : 0).opacity(animate ? 0 : 1).animation(.easeOut(duration: 1.5).delay(p.delay), value: animate) } }.onAppear { animate = true } }
}
