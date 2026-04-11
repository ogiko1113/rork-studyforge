import SwiftUI
import UIKit

struct DeckDetailView: View {
    @Environment(StudyDataStore.self) private var store
    let deckName: String
    @State private var editingCard: Card?
    @State private var toastMessage: String?

    private var deckCards: [Card] {
        store.cardsForDeck(deckName).sorted { $0.nextReview < $1.nextReview }
    }

    private var dueCount: Int {
        let now = DateHelper.nowMillis()
        return deckCards.filter { $0.nextReview <= now }.count
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Label("\(deckCards.count)枚", systemImage: "rectangle.stack")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Label("\(dueCount)枚 期限", systemImage: "clock")
                        .foregroundStyle(dueCount > 0 ? AppColors.accent : .secondary)
                }
                .font(.caption.weight(.medium))
            }

            Section {
                ForEach(deckCards) { card in
                    Button {
                        editingCard = card
                    } label: {
                        cardRow(card: card)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation { store.deleteCard(card) }
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .overlay {
            if deckCards.isEmpty {
                ContentUnavailableView(
                    "カードがありません",
                    systemImage: "rectangle.on.rectangle",
                    description: Text("このデッキにはカードがありません")
                )
            }
        }
        .navigationTitle(deckName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingCard) { card in
            CardEditSheet(card: card)
        }
        .toast(message: $toastMessage)
    }

    private func cardRow(card: Card) -> some View {
        let isDue = card.nextReview <= DateHelper.nowMillis()
        return HStack(spacing: 10) {
            if let name = card.imageFront,
               let img = ImageStorageService.loadImage(filename: name) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(.rect(cornerRadius: 6))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(card.front)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(DateHelper.formatDateTime(card.nextReview))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isDue {
                Circle()
                    .fill(AppColors.accent)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 2)
    }
}
