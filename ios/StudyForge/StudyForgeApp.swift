import SwiftUI

@main
struct StudyForgeApp: App {
    @State private var store = StudyDataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
