import SwiftUI
import SwiftData

// MARK: - FORM VIEW
struct HabitFormView: View {
    @Environment(\.modelContext) private var modelContext; @Environment(\.dismiss) var dismiss
    var currentLevel: Int; var habitToEdit: Habit? = nil; var nextOrder: Int = 0
    @State private var name = ""; @State private var icon = "figure.run"; @State private var cat = "Personal"; @State private var goal = 5; @State private var color = "Blue"
    @State private var scheduledDays: Set<Int> = [1,2,3,4,5,6,7]
    @State private var isTimer = false; @State private var duration = 25
    @State private var remind = false; @State private var type = "Single"; @State private var mins = 60; @State private var count = 3; @State private var start = Date()
    @State private var showToast = false; @State private var toastMessage = ""
    let colorOpts = [("Blue", 1), ("Green", 1), ("Orange", 1), ("Purple", 1), ("Red", 1), ("Teal", 10), ("Indigo", 10), ("Pink", 20), ("Mint", 20), ("Gold", 50)]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Form {
                    Section("Details") { TextField("Name", text: $name); Picker("Category", selection: $cat) { ForEach(["Health", "Fitness", "Work", "Personal", "Mindset"], id: \.self) { Text($0) } } }
                    Section("Schedule") {
                        HStack {
                            let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                            ForEach(1...7, id: \.self) { day in
                                Text(weekDays[day-1].prefix(1)).font(.caption.bold()).frame(maxWidth: .infinity).padding(.vertical, 8).background(scheduledDays.contains(day) ? Color.blue : Color.secondary.opacity(0.1)).foregroundStyle(scheduledDays.contains(day) ? .white : .primary).clipShape(Circle()).onTapGesture { if scheduledDays.contains(day) { scheduledDays.remove(day) } else { scheduledDays.insert(day) } }
                            }
                        }
                    }
                    Section("Icon") { SymbolPicker(selectedSymbol: $icon) }
                    Section("Type") { Toggle("Focus Timer", isOn: $isTimer); if isTimer { Stepper("\(duration) mins", value: $duration, in: 1...120) } }
                    Section("Theme Color") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(colorOpts, id: \.0) { opt in
                                    let locked = currentLevel < opt.1
                                    VStack(spacing: 4) {
                                        ZStack { Circle().fill(getRealColor(opt.0).opacity(0.8)).frame(width: 35, height: 35).overlay(Circle().stroke(Color.primary, lineWidth: color == opt.0 ? 3 : 0)); if locked { Image(systemName: "lock.fill").font(.system(size: 10)).foregroundStyle(.white) } }
                                        Text(opt.0).font(.system(size: 8, weight: .bold)).foregroundStyle(.secondary)
                                    }.onTapGesture { if locked { triggerToast("Level \(opt.1) needed") } else { color = opt.0; SoundManager.instance.playPop() } }
                                }
                            }.padding(.vertical, 5)
                        }
                    }
                    Section("Goal") { Stepper("Daily Goal: \(goal)", value: $goal, in: 1...100) }
                    Section("Reminders") {
                        Toggle("Enable", isOn: $remind)
                        if remind {
                            Picker("Style", selection: $type) { Text("Once").tag("Single"); Text("Hourly").tag("Interval") }.pickerStyle(.segmented)
                            DatePicker("Start", selection: $start, displayedComponents: .hourAndMinute)
                            if type == "Interval" { Stepper("Every \(mins) mins", value: $mins, in: 15...240, step: 15); Stepper("\(count) times", value: $count, in: 1...12) }
                        }
                    }
                }
                if showToast { Text(toastMessage).font(.system(size: 14, design: .rounded)).padding(.horizontal, 16).padding(.vertical, 10).background(.ultraThinMaterial).clipShape(Capsule()).shadow(radius: 10).transition(.move(edge: .top).combined(with: .opacity)).zIndex(1).padding(.top, 10) }
            }
            .navigationTitle(habitToEdit == nil ? "New" : "Edit")
            .onAppear { if let h = habitToEdit { name = h.name; icon = h.icon; goal = h.goal; color = h.colorName; cat = h.category; scheduledDays = Set(h.scheduledDays); isTimer = h.isTimerHabit; duration = h.timerDurationMinutes; remind = h.reminderEnabled; type = h.reminderType; mins = h.intervalMinutes; count = h.intervalCount; start = h.startTime } }
            .toolbar { Button("Save") {
                let h = habitToEdit ?? Habit(name: name, icon: icon, goal: goal, colorName: color, category: cat, sortOrder: nextOrder)
                if habitToEdit != nil { h.name = name; h.icon = icon; h.goal = goal; h.colorName = color; h.category = cat }
                h.scheduledDays = Array(scheduledDays).sorted(); h.isTimerHabit = isTimer; h.timerDurationMinutes = duration; h.reminderEnabled = remind; h.reminderType = type; h.intervalMinutes = mins; h.intervalCount = count; h.startTime = start
                if habitToEdit == nil { modelContext.insert(h) }
                NotificationManager.instance.scheduleReminders(for: h); dismiss()
            }.disabled(name.isEmpty || scheduledDays.isEmpty) }
        }
    }
    func triggerToast(_ msg: String) { toastMessage = msg; withAnimation(.spring()) { showToast = true }; DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { showToast = false } } }
    func getRealColor(_ n: String) -> Color {
        switch n { case "Blue": return .blue; case "Green": return .green; case "Orange": return .orange; case "Purple": return .purple; case "Red": return .red; case "Teal": return .teal; case "Indigo": return .indigo; case "Pink": return .pink; case "Mint": return .mint; case "Gold": return Color(red: 1, green: 0.84, blue: 0); default: return .blue }
    }
}
