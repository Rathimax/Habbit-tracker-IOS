import SwiftUI
import SwiftData

// MARK: - TRENDS & HALL OF FAME
struct InsightsView: View {
    let habits: [Habit]; let stats: UserStats; @Environment(\.dismiss) var dismiss
    @State private var selectedBadge: Badge? = nil
    let allBadges = [
        Badge(name: "First Win", icon: "bolt.fill", description: "Complete your very first task."),
        Badge(name: "Rising Star", icon: "star.fill", description: "Reach Level 10."),
        Badge(name: "Consistent", icon: "flame.fill", description: "Reach a 7-day streak."),
        Badge(name: "Deep Work", icon: "timer", description: "Finish 10 focus sessions."),
        Badge(name: "Centurion", icon: "shield.fill", description: "Complete a habit 100 times."),
        Badge(name: "Legendary", icon: "crown.fill", description: "Reach Level 50.")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Hall of Fame").font(.headline).padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(allBadges) { b in
                                    let unlocked = stats.unlockedBadges.contains(b.name)
                                    VStack { Image(systemName: b.icon).font(.title).foregroundStyle(unlocked ? .orange : .secondary.opacity(0.2)).padding().background(unlocked ? Color.orange.opacity(0.1) : Color.secondary.opacity(0.05)).clipShape(Circle()); Text(b.name).font(.caption2.bold()).opacity(unlocked ? 1 : 0.5) }.frame(width: 85).onTapGesture { selectedBadge = b }
                                }
                            }.padding(.horizontal)
                        }
                    }
                    HeatmapView(habits: habits).padding(.horizontal)
                    VStack(spacing: 15) { LabeledContent("Lifetime Wins", value: "\(habits.reduce(0) { $0 + $1.totalCompletionsEver })"); Divider(); LabeledContent("Timed Sessions", value: "\(habits.reduce(0) { $0 + $1.timedSessionsCompleted })") }.padding().background(Color(uiColor: .secondarySystemGroupedBackground)).clipShape(RoundedRectangle(cornerRadius: 20)).padding(.horizontal)
                }.padding(.top)
                
                NavigationLink(destination: AnalyticsView(habits: habits)) {
                    Text("View Advanced Analytics")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Trends").background(Color(uiColor: .systemGroupedBackground)).toolbar { Button("Done") { dismiss() } }
            .alert(item: $selectedBadge) { b in Alert(title: Text(b.name), message: Text("\(b.description)"), dismissButton: .default(Text("Got it!"))) }
        }
    }
}
