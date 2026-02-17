import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var activeSession: WorkoutSession?
    @State private var restTimerService = RestTimerService()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            StartSessionView(activeSession: $activeSession)
                .tabItem {
                    Label("Entraînement", systemImage: "figure.strengthtraining.traditional")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("Historique", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)

            ExerciseListView()
                .tabItem {
                    Label("Exercices", systemImage: "dumbbell")
                }
                .tag(2)

            TemplateListView()
                .tabItem {
                    Label("Modèles", systemImage: "doc.text")
                }
                .tag(3)
        }
        .fullScreenCover(item: $activeSession) { session in
            ActiveSessionView(
                activeSession: $activeSession,
                restTimerService: restTimerService
            )
        }
        .onAppear {
            checkForDraftSession()
        }
    }

    private func checkForDraftSession() {
        let status = SessionStatus.inProgress
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate<WorkoutSession> { $0.status == status },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        // Don't auto-open; the StartSessionView shows a "Resume" banner
    }
}

// WorkoutSession already has a UUID `id` property.
// Make it conform to Identifiable for .fullScreenCover(item:)
extension WorkoutSession: Identifiable {}
