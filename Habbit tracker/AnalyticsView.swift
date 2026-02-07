import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    var habits: [Habit]
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "This Week"
        case month = "This Month"
        var id: String { self.rawValue }
    }
    
    struct DailyCompletion: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
    }
    
    var data: [DailyCompletion] {
        let calendar = Calendar.current
        let today = Date()
        let range = selectedTimeRange == .week ? 7 : 30
        
        return (0..<range).map { i in
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let dateString = formatDate(date)
            let count = habits.reduce(0) { $0 + ($1.completionHistory[dateString] ?? 0) }
            return DailyCompletion(date: date, count: count)
        }.reversed()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text("Total Completions").font(.headline)
                
                Chart(data) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Completions", item.count)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 250)
                .chartXAxis {
                    AxisMarks(values: .stride(by: selectedTimeRange == .week ? .day : .day)) { value in
                        if value.as(Date.self) != nil {
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        }
                    }
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Analytics")
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
