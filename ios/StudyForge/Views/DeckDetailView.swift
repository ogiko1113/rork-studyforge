import SwiftUI

struct DeckDetailView: View {
    @Environment(StudyDataStore.self) private var store
    let deckName: String
    @State private var editingCard: Card?
    @State private var toastMessage: String?

    private var deckCards: [Card] {
        store.cardsForDeck(deckName)
    }

    var body: some View {
        List {
            ForEach(deckCards) { card in
                Button {
                    editingCard = card
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.front)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(card.back)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 2)
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
}

struct CardEditSheet: View {
    @Environment(StudyDataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let card: Card
    @State private var front: String
    @State private var back: String

    init(card: Card) {
        self.card = card
        _front = State(initialValue: card.front)
        _back = State(initialValue: card.back)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("表面（問題）") {
                    TextField("問題を入力", text: $front, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("裏面（答え）") {
                    TextField("答えを入力", text: $back, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("カードを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        store.updateCard(card, front: front, back: back, deck: card.deck)
                        dismiss()
                    }
                    .disabled(front.trimmingCharacters(in: .whitespaces).isEmpty || back.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
