import SwiftUI
import SwiftData
import UserNotifications

@main
struct Habbit_trackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Habit.self, UserStats.self])
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "COMPLETE_ACTION" {
            let userInfo = response.notification.request.content.userInfo
            if let habitIDString = userInfo["habitID"] as? String, let uuid = UUID(uuidString: habitIDString) {
                completeHabit(with: uuid)
            }
        }
        completionHandler()
    }
    
    private func completeHabit(with id: UUID) {
        do {
            let config = ModelConfiguration()
            let container = try ModelContainer(for: Habit.self, UserStats.self, configurations: config)
            let context = ModelContext(container)
            
            var descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == id })
            descriptor.fetchLimit = 1
            
            if let habit = try context.fetch(descriptor).first {
                let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
                let today = f.string(from: Date())
                
                // Only increment if goal not reached (or just increment anyway, similar to UI)
                // Logic from HabitRowView:
                if habit.completionCount < habit.goal {
                    habit.completionCount += 1
                    habit.completionHistory[today, default: 0] += 1
                    
                    // Update XP/Stats if goal reached
                    if habit.completionCount == habit.goal && habit.lastXPDate != today {
                         habit.totalCompletionsEver += 1
                         habit.lastXPDate = today
                         
                         // We also need to fetch UserStats to update XP
                         // But since UserStats is a singleton-like entry, we just fetch the first one
                         var statsDesc = FetchDescriptor<UserStats>()
                         statsDesc.fetchLimit = 1
                         if let stats = try context.fetch(statsDesc).first {
                             stats.totalXP += 10
                         }
                    }
                    try context.save()
                    print("Habit \(habit.name) completed from notification!")
                }
            }
        } catch {
            print("Failed to complete habit from notification: \(error)")
        }
    }
}
