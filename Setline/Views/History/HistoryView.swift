import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query private var sessions: [WorkoutSession]

    init() {
        _sessions = Query(
            filter: #Predicate<WorkoutSession> { $0.isFinished == true },
            sort: \WorkoutSession.startedAt,
            order: .reverse
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("Aucun historique")
                            .font(.headline)
                        Text("Terminez un entraînement pour le voir apparaître ici.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                } else {
                    List {
                        ForEach(groupedByMonth, id: \.key) { month, monthSessions in
                            Section {
                                ForEach(monthSessions, id: \.id) { session in
                                    NavigationLink {
                                        SessionDetailView(session: session)
                                    } label: {
                                        SessionHistoryRow(session: session)
                                    }
                                }
                            } header: {
                                Text(month)
                                    .font(.subheadline.weight(.semibold))
                                    .textCase(nil)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Historique")
        }
    }

    private var groupedByMonth: [(key: String, value: [WorkoutSession])] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "MMMM yyyy"

        var grouped: [(key: String, value: [WorkoutSession])] = []
        var currentMonth = ""
        var currentSessions: [WorkoutSession] = []

        for session in sessions {
            let month = formatter.string(from: session.startedAt).capitalized
            if month != currentMonth {
                if !currentSessions.isEmpty {
                    grouped.append((key: currentMonth, value: currentSessions))
                }
                currentMonth = month
                currentSessions = [session]
            } else {
                currentSessions.append(session)
            }
        }
        if !currentSessions.isEmpty {
            grouped.append((key: currentMonth, value: currentSessions))
        }

        return grouped
    }
}

// MARK: - Session Row

private struct SessionHistoryRow: View {
    let session: WorkoutSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(session.sourceTemplateName ?? "Séance libre")
                    .font(.body.weight(.medium))
                Spacer()
                if let duration = sessionDuration {
                    Text(duration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(formattedDate(session.startedAt))
                .font(.caption)
                .foregroundStyle(.secondary)

            let exerciseNames = uniqueExerciseNames
            if !exerciseNames.isEmpty {
                Text(exerciseNames.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 16) {
                Label("\(session.sets.count) séries", systemImage: "checkmark.circle")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                let totalVolume = session.sets
                    .filter { $0.isCompleted }
                    .reduce(0.0) { $0 + (Double($1.reps ?? 0) * ($1.load ?? 0)) }
                if totalVolume > 0 {
                    Label("\(Int(totalVolume)) kg", systemImage: "scalemass")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var uniqueExerciseNames: [String] {
        var seen = Set<UUID>()
        var names: [String] = []
        let sorted = session.sets.sorted { $0.exerciseOrderIndex < $1.exerciseOrderIndex }
        for set in sorted {
            guard let exercise = set.exercise, !seen.contains(exercise.id) else { continue }
            seen.insert(exercise.id)
            names.append(exercise.name)
        }
        return names
    }

    private var sessionDuration: String? {
        guard let end = session.endedAt else { return nil }
        let interval = end.timeIntervalSince(session.startedAt)
        let minutes = Int(interval) / 60
        if minutes >= 60 {
            return "\(minutes / 60)h\(String(format: "%02d", minutes % 60))"
        }
        return "\(minutes) min"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Session Detail View

struct SessionDetailView: View {
    let session: WorkoutSession

    var body: some View {
        List {
            // Session info header
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    if let templateName = session.sourceTemplateName {
                        Text(templateName)
                            .font(.title3.weight(.semibold))
                    } else {
                        Text("Séance libre")
                            .font(.title3.weight(.semibold))
                    }

                    HStack(spacing: 16) {
                        Label(formattedDate(session.startedAt), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let duration = sessionDuration {
                            Label(duration, systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 16) {
                        Label("\(session.sets.count) séries", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        let totalVolume = session.sets
                            .filter { $0.isCompleted }
                            .reduce(0.0) { $0 + (Double($1.reps ?? 0) * ($1.load ?? 0)) }
                        if totalVolume > 0 {
                            Label("\(Int(totalVolume)) kg volume total", systemImage: "scalemass")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Exercise groups
            ForEach(exerciseGroups, id: \.exerciseId) { group in
                Section {
                    ForEach(group.sets, id: \.id) { set in
                        HStack {
                            Text("Série \(set.setNumber)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 60, alignment: .leading)

                            Spacer()

                            if let reps = set.reps {
                                Text("\(reps) reps")
                                    .font(.subheadline)
                            } else {
                                Text("–")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                            }

                            Spacer()

                            if let load = set.load {
                                Text("\(load, specifier: "%.1f") kg")
                                    .font(.subheadline.weight(.medium))
                            } else {
                                Text("–")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                } header: {
                    Text(group.exerciseName)
                        .font(.subheadline.weight(.semibold))
                        .textCase(nil)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Détail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private struct ExerciseGroupData {
        let exerciseId: UUID
        let exerciseName: String
        let sets: [WorkoutSet]
    }

    private var exerciseGroups: [ExerciseGroupData] {
        let sorted = session.sets.sorted {
            if $0.exerciseOrderIndex != $1.exerciseOrderIndex {
                return $0.exerciseOrderIndex < $1.exerciseOrderIndex
            }
            return $0.setNumber < $1.setNumber
        }

        var groups: [ExerciseGroupData] = []
        var currentId: UUID?
        var currentSets: [WorkoutSet] = []
        var currentName = ""

        for set in sorted {
            guard let exercise = set.exercise else { continue }
            if exercise.id != currentId {
                if let id = currentId, !currentSets.isEmpty {
                    groups.append(ExerciseGroupData(exerciseId: id, exerciseName: currentName, sets: currentSets))
                }
                currentId = exercise.id
                currentName = exercise.name
                currentSets = [set]
            } else {
                currentSets.append(set)
            }
        }
        if let id = currentId, !currentSets.isEmpty {
            groups.append(ExerciseGroupData(exerciseId: id, exerciseName: currentName, sets: currentSets))
        }

        return groups
    }

    private var sessionDuration: String? {
        guard let end = session.endedAt else { return nil }
        let interval = end.timeIntervalSince(session.startedAt)
        let minutes = Int(interval) / 60
        if minutes >= 60 {
            return "\(minutes / 60)h\(String(format: "%02d", minutes % 60))"
        }
        return "\(minutes) min"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
