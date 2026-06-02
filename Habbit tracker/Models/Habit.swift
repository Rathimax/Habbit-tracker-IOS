import Foundation
import SwiftData
import SwiftUI

@Model
class Habit {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "figure.run"
    var category: String = "Personal"
    var goal: Int = 5
    var colorName: String = "Blue"
    var completionCount: Int = 0
    var totalCompletionsEver: Int = 0
    var completionHistory: [String: Int] = [:]
    var skippedDays: [String] = []
    var sortOrder: Int = 0
    var lastXPDate: String = ""
    var scheduledDays: [Int] = [1, 2, 3, 4, 5, 6, 7]

    var isTimerHabit: Bool = false
    var timerDurationMinutes: Int = 25
    var timedSessionsCompleted: Int = 0
    var isArchived: Bool = false
    
    var reminderEnabled: Bool = false
    var reminderType: String = "Single"
    var intervalMinutes: Int = 60
    var intervalCount: Int = 3
    var startTime: Date = Date()

    init(name: String, icon: String, goal: Int, colorName: String, category: String = "Personal", sortOrder: Int = 0) {
        self.name = name; self.icon = icon; self.goal = goal; self.colorName = colorName; self.category = category; self.sortOrder = sortOrder
    }

    var themeColor: Color {
        switch colorName {
        case "Blue": return .blue; case "Green": return .green; case "Orange": return .orange
        case "Purple": return .purple; case "Red": return .red; case "Teal": return .teal
        case "Indigo": return .indigo; case "Pink": return .pink; case "Mint": return .mint
        case "Gold": return Color(red: 1, green: 0.84, blue: 0); default: return .blue
        }
    }
    
    var cardGradient: LinearGradient {
        LinearGradient(colors: [themeColor.opacity(0.22), themeColor.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

@Model
class UserStats {
    var globalStreak: Int = 0
    var totalXP: Int = 0
    var lastGlobalSuccessDate: String = ""
    var lastAppOpenDate: String = ""
    var unlockedBadges: [String] = []
    var currentLevel: Int { (totalXP / 100) + 1 }
    var xpInLevel: Int { totalXP % 100 }
    init() {}
}
