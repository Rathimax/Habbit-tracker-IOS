import SwiftUI
import AVFoundation
import UserNotifications

// MARK: - MANAGERS
class SoundManager {
    static let instance = SoundManager()
    func playPop() { 
        AudioServicesPlaySystemSound(1104)
        let generator = UIImpactFeedbackGenerator(style: .medium); generator.impactOccurred()
    }
    func playSuccess() { 
        AudioServicesPlaySystemSound(1407)
        let generator = UINotificationFeedbackGenerator(); generator.notificationOccurred(.success)
    }
}

class NotificationManager {
    static let instance = NotificationManager()
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                let completeAction = UNNotificationAction(identifier: "COMPLETE_ACTION", title: "Complete", options: .foreground)
                let category = UNNotificationCategory(identifier: "HABIT_REMINDER", actions: [completeAction], intentIdentifiers: [], options: [])
                UNUserNotificationCenter.current().setNotificationCategories([category])
            }
        }
    }
    func cancelReminders(for habit: Habit) {
        let ids = (0...20).map { "\(habit.id.uuidString)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
    func scheduleReminders(for habit: Habit) {
        cancelReminders(for: habit)
        guard habit.reminderEnabled && habit.completionCount < habit.goal else { return }
        let content = UNMutableNotificationContent()
        content.title = "TIME FOR \(habit.name.uppercased())"; content.body = "Don't break your streak!"; content.sound = .default
        content.categoryIdentifier = "HABIT_REMINDER"
        content.userInfo = ["habitID": habit.id.uuidString]
        if habit.reminderType == "Single" {
            let comp = Calendar.current.dateComponents([.hour, .minute], from: habit.startTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: true)
            let request = UNNotificationRequest(identifier: "\(habit.id.uuidString)-0", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        } else {
            for i in 0..<habit.intervalCount {
                let triggerDate = habit.startTime.addingTimeInterval(Double(i * habit.intervalMinutes * 60))
                let comp = Calendar.current.dateComponents([.hour, .minute], from: triggerDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: true)
                let request = UNNotificationRequest(identifier: "\(habit.id.uuidString)-\(i)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}
