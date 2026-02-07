import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                Image(systemName: "checklist.checked")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(spacing: 15) {
                    Text("Welcome to Habit Tracker")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Build better habits, track your progress, and level up your life.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                VStack(alignment: .leading, spacing: 30) {
                    FeatureRow(icon: "target", title: "Set Goals", desc: "Define your daily habits and stick to them.")
                    FeatureRow(icon: "chart.xyaxis.line", title: "Track Progress", desc: "Visualize your success with beautiful charts.")
                    FeatureRow(icon: "medal.fill", title: "Earn Rewards", desc: "Unlock badges and level up as you stay consistent.")
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                    withAnimation {
                        hasSeenOnboarding = true
                    }
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline)
                Text(desc).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}
