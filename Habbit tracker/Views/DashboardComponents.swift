import SwiftUI
import SwiftData

struct EmptyHabitsStateView: View {
    @Binding var showingAddHabit: Bool
    
    var body: some View {
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
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)
            .listRowBackground(Color.clear)
        }
    }
}

struct ArchivedHabitsSection: View {
    var archivedHabits: [Habit]
    @Binding var isArchiveExpanded: Bool
    
    var body: some View {
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
            .listRowBackground(Color.secSysGroupedBackground.opacity(0.5))
            .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        }
    }
}
