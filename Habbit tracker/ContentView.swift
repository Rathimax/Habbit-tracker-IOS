import SwiftUI
import SwiftData
import AVFoundation
import UserNotifications
import Combine

// MARK: - MAIN CONTENT VIEW
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.sortOrder) var allHabits: [Habit]
    @Query var stats: [UserStats]
    
    @State private var showingAddHabit = false
    @State private var showingInsights = false
    @State private var habitToEdit: Habit? = nil
    @State private var showConfetti = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var editMode: EditMode = .inactive
    @State private var isArchiveExpanded = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var habits: [Habit] { allHabits.filter { !$0.isArchived } }
    var archivedHabits: [Habit] { allHabits.filter { $0.isArchived } }
    
    var currentStats: UserStats {
        if let first = stats.first { return first }
        let new = UserStats(); modelContext.insert(new); return new
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                List {
                    Section {
                        QuoteView().padding(.bottom, 5)
                        DashboardCard(stats: currentStats)
                    }
                    .listRowBackground(Color.clear).listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))

                    let todayWeekday = Calendar.current.component(.weekday, from: Date())
                    ForEach(["Health", "Fitness", "Work", "Personal", "Mindset"], id: \.self) { cat in
                        let filtered = habits.filter { $0.category == cat && $0.scheduledDays.contains(todayWeekday) }
                        if !filtered.isEmpty {
                            Section(header: Text(cat).font(.subheadline.bold()).padding(.top, 10)) {
                                ForEach(filtered) { habit in
                                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                                        HabitRowView(habit: habit, stats: currentStats) { checkGlobalStreak() }
                                    }
                                    .contextMenu {
                                        Button { habitToEdit = habit } label: { Label("Edit", systemImage: "pencil") }
                                        Button { skipHabit(habit) } label: { Label("Skip Today", systemImage: "arrowshape.turn.up.right") }
                                        Button { habit.isArchived = true } label: { Label("Archive", systemImage: "archivebox") }
                                        Button(role: .destructive) { NotificationManager.instance.cancelReminders(for: habit); modelContext.delete(habit) } label: { Label("Delete", systemImage: "trash") }
                                    }
                                    .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)).listRowBackground(Color.clear).listRowSeparator(.hidden)
                                }.onMove(perform: moveHabits)
                            }
                        }
                    }
                    
                    if !archivedHabits.isEmpty {
                        Section {
                            DisclosureGroup(isExpanded: $isArchiveExpanded) {
                                ForEach(archivedHabits) { h in
                                    HStack(spacing: 15) {
                                        Group { if h.icon.count > 2 { Image(systemName: h.icon) } else { Text(h.icon) } }
                                            .font(.system(size: 18)).padding(8).background(Color.secondary.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 8))
                                        Text(h.name).font(.subheadline).foregroundStyle(.secondary)
                                        Spacer()
                                        Button("Restore") { h.isArchived = false }.font(.caption.bold()).buttonStyle(.bordered).tint(.blue)
                                    }.padding(.vertical, 8)
                                }
                            } label: {
                                Label("Archive (\(archivedHabits.count))", systemImage: "archivebox").font(.subheadline.bold()).foregroundStyle(.secondary)
                            }
                        }
                        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.5))
                        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    }
                    
                    if habits.isEmpty && archivedHabits.isEmpty {
                        Section {
                            VStack(spacing: 20) {
                                Image(systemName: "list.clipboard")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.secondary.opacity(0.3))
                                Text("No habits yet!")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Button("Create your first habit") { showingAddHabit = true }
                                    .font(.subheadline.bold())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 50)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(.plain).environment(\.editMode, $editMode)
                if showConfetti { ConfettiView().ignoresSafeArea() }
            }
            .fullScreenCover(isPresented: Binding(get: { !hasSeenOnboarding }, set: { _ in })) {
                 OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button { isDarkMode.toggle() } label: { Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill").foregroundStyle(isDarkMode ? .yellow : .blue) }
                    Button { showingInsights.toggle() } label: { Image(systemName: "chart.bar.xaxis") }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { withAnimation { editMode = (editMode == .active ? .inactive : .active) } } label: { Text(editMode == .active ? "Done" : "Edit").font(.subheadline.bold()) }
                    Button { showingAddHabit = true } label: { Image(systemName: "plus.circle.fill").font(.title2) }
                }
            }
            .sheet(isPresented: $showingAddHabit) { HabitFormView(currentLevel: currentStats.currentLevel, nextOrder: habits.count) }
            .sheet(item: $habitToEdit) { h in HabitFormView(currentLevel: currentStats.currentLevel, habitToEdit: h) }
            .sheet(isPresented: $showingInsights) { InsightsView(habits: allHabits, stats: currentStats) }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear { NotificationManager.instance.requestPermission(); checkNewDay() }
        }
    }

    func moveHabits(from s: IndexSet, to d: Int) {
        var updated = habits; updated.move(fromOffsets: s, toOffset: d)
        for i in 0..<updated.count { updated[i].sortOrder = i }
    }
    
    func checkNewDay() {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; let today = f.string(from: Date())
        if currentStats.lastAppOpenDate != today {
            for h in allHabits { h.completionCount = 0; if h.reminderEnabled { NotificationManager.instance.scheduleReminders(for: h) } }
            currentStats.lastAppOpenDate = today
        }
    }

    func checkGlobalStreak() {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; let today = f.string(from: Date())
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        guard currentStats.lastGlobalSuccessDate != today else { return }
        let scheduledToday = habits.filter { $0.scheduledDays.contains(todayWeekday) }
        if scheduledToday.allSatisfy({ h in 
            let skipped = h.skippedDays.contains(today)
            return h.completionCount >= h.goal || skipped
        }) && !scheduledToday.isEmpty {
            currentStats.globalStreak += 1; currentStats.lastGlobalSuccessDate = today
            currentStats.totalXP += 50; SoundManager.instance.playSuccess(); showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showConfetti = false }
        }
        // Manual Badge check to prevent compiler timeout
        if currentStats.totalXP >= 10 && !currentStats.unlockedBadges.contains("First Win") { currentStats.unlockedBadges.append("First Win") }
        if currentStats.currentLevel >= 10 && !currentStats.unlockedBadges.contains("Rising Star") { currentStats.unlockedBadges.append("Rising Star") }
        if currentStats.globalStreak >= 7 && !currentStats.unlockedBadges.contains("Consistent") { currentStats.unlockedBadges.append("Consistent") }
        if allHabits.reduce(0, {$0 + $1.timedSessionsCompleted}) >= 10 && !currentStats.unlockedBadges.contains("Deep Work") { currentStats.unlockedBadges.append("Deep Work") }
    }
    
    func skipHabit(_ habit: Habit) {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; let today = f.string(from: Date())
        if !habit.skippedDays.contains(today) {
            habit.skippedDays.append(today)
            checkGlobalStreak()
        }
    }
}
