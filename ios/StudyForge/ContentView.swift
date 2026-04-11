import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("ホーム", systemImage: "house.fill", value: 0) {
                HomeView(selectedTab: $selectedTab)
            }
            Tab("復習", systemImage: "book.fill", value: 1) {
                ReviewView(selectedTab: $selectedTab)
            }
            Tab("追加", systemImage: "plus.circle.fill", value: 2) {
                AddCardView()
            }
            Tab("統計", systemImage: "chart.bar.fill", value: 3) {
                StatsView()
            }
        }
        .tint(AppColors.accent)
    }
}
