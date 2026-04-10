import SwiftUI

struct HomeView: View {
    @Environment(StudyDataStore.self) private var store
    @State private var deckToDelete: String?
    @State private var showDeleteAlert = false
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                if store.sortedDecks.isEmpty {
                    emptyState
                        .frame(maxWidth: .infinity)
                        .padding(.top, 120)
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(store.sortedDecks) { deck in
                            NavigationLink(value: deck.name) {
                                DeckCardView(
                                    deckName: deck.name,
                                    cardCount: deck.cardCount,
                                    dueCount: deck.dueCount
                                )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    deckToDelete = deck.name
                                    showDeleteAlert = true
                                } label: {
                                    Label("デッキを削除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("StudyForge")
            .navigationDestination(for: String.self) { deckName in
                DeckDetailView(deckName: deckName)
            }
            .alert("デッキを削除", isPresented: $showDeleteAlert) {
                Button("削除", role: .destructive) {
                    if let deck = deckToDelete {
                        withAnimation { store.deleteDeck(deck) }
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("「\(deckToDelete ?? "")」のすべてのカードと学習履歴が削除されます。")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("デッキがありません")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            Text("カードを追加して学習を始めましょう")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                selectedTab = 2
            } label: {
                Text("カードを追加しよう")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.accent.gradient)
                    .clipShape(.capsule)
            }
            .padding(.top, 8)
        }
    }
}
