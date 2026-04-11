import SwiftUI

@main
struct StudyForgeApp: App {
    @State private var store = StudyDataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .task {
                    _ = await NotificationService.shared.requestPermission()
                    let count = store.dueByTomorrowMorning()
                    await NotificationService.shared.rescheduleReviewReminder(dueCount: count)
                }
        }
    }
}
