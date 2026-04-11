import SwiftUI
import UIKit
import PhotosUI

struct AddCardView: View {
    @Environment(StudyDataStore.self) private var store
    @State private var mode: Int = 0
    @State private var selectedDeck: String = ""
    @State private var newDeckName: String = ""
    @State private var selectedCourseId: String = ""
    @State private var front: String = ""
    @State private var back: String = ""
    @State private var bulkText: String = ""
    @State private var toastMessage: String?
    @State private var frontPickerItem: PhotosPickerItem?
    @State private var backPickerItem: PhotosPickerItem?
    @State private var frontImage: UIImage?
    @State private var backImage: UIImage?
    @FocusState private var frontFocused: Bool

    private var effectiveDeck: String {
        let trimmed = newDeckName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { return trimmed }
        return selectedDeck
    }

    private var isNewDeck: Bool {
        let trimmed = newDeckName.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && !store.deckNames.contains(trimmed)
    }

    private var parsedCards: [ParsedCard] {
        ImportParser.parse(bulkText)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    deckSection
                    modeSelector
                    if mode == 0 {
                        singleAddSection
                    } else {
                        bulkAddSection
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("カード追加")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toast(message: $toastMessage)
    }

    private var deckSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("デッキ")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if !store.deckNames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(store.deckNames, id: \.self) { deck in
                            Button {
                                selectedDeck = deck
                                newDeckName = ""
                            } label: {
                                Text(deck)
                                    .font(.caption.weight(.medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedDeck == deck && newDeckName.isEmpty ? AppColors.accent.opacity(0.15) : Color(.tertiarySystemGroupedBackground))
                                    .foregroundStyle(selectedDeck == deck && newDeckName.isEmpty ? AppColors.accent : .secondary)
                                    .clipShape(.capsule)
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
            }

            TextField("新しいデッキ名", text: $newDeckName)
                .textFieldStyle(.roundedBorder)

            if isNewDeck && !store.courses.isEmpty {
                coursePickerSection
            }
        }
    }

    private var coursePickerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("コースに追加（任意）")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        selectedCourseId = ""
                    } label: {
                        Text("なし")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedCourseId.isEmpty ? AppColors.accent.opacity(0.15) : Color(.tertiarySystemGroupedBackground))
                            .foregroundStyle(selectedCourseId.isEmpty ? AppColors.accent : .secondary)
                            .clipShape(.capsule)
                    }

                    ForEach(store.courses) { course in
                        Button {
                            selectedCourseId = course.id
                        } label: {
                            Text(course.name)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedCourseId == course.id ? AppColors.accent.opacity(0.15) : Color(.tertiarySystemGroupedBackground))
                                .foregroundStyle(selectedCourseId == course.id ? AppColors.accent : .secondary)
                                .clipShape(.capsule)
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 0)
        }
    }

    private var modeSelector: some View {
        SegmentedControlView(selection: $mode, titles: ["単体追加", "一括追加"])
    }

    private var singleAddSection: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("表面（問題）")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                TextField("問題を入力", text: $front, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
                    .focused($frontFocused)
                imagePickerRow(
                    image: frontImage,
                    pickerItem: $frontPickerItem,
                    onRemove: {
                        frontImage = nil
                        frontPickerItem = nil
                    }
                )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("裏面（答え）")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                TextField("答えを入力", text: $back, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
                imagePickerRow(
                    image: backImage,
                    pickerItem: $backPickerItem,
                    onRemove: {
                        backImage = nil
                        backPickerItem = nil
                    }
                )
            }

            Button {
                addSingleCard()
            } label: {
                Text("追加")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(canAddSingle ? AppColors.accent.gradient : Color.gray.gradient)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .disabled(!canAddSingle)
        }
        .onChange(of: frontPickerItem) { _, newItem in
            loadPickedImage(item: newItem) { img in
                if let img { frontImage = img }
            }
        }
        .onChange(of: backPickerItem) { _, newItem in
            loadPickedImage(item: newItem) { img in
                if let img { backImage = img }
            }
        }
    }

    @ViewBuilder
    private func imagePickerRow(
        image: UIImage?,
        pickerItem: Binding<PhotosPickerItem?>,
        onRemove: @escaping () -> Void
    ) -> some View {
        if let image {
            HStack(spacing: 10) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(.rect(cornerRadius: 8))

                PhotosPicker(selection: pickerItem, matching: .images) {
                    Text("変更")
                        .font(.caption.weight(.medium))
                }

                Spacer()

                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        } else {
            PhotosPicker(selection: pickerItem, matching: .images) {
                Label("画像を追加", systemImage: "photo.badge.plus")
                    .font(.caption.weight(.medium))
            }
            .padding(.top, 2)
        }
    }

    private func loadPickedImage(item: PhotosPickerItem?, completion: @escaping @MainActor (UIImage?) -> Void) {
        guard let item else { return }
        Task {
            let data = try? await item.loadTransferable(type: Data.self)
            await MainActor.run {
                if let data, let img = UIImage(data: data) {
                    completion(img)
                } else {
                    completion(nil)
                }
            }
        }
    }

    private var canAddSingle: Bool {
        !front.trimmingCharacters(in: .whitespaces).isEmpty &&
        !back.trimmingCharacters(in: .whitespaces).isEmpty &&
        !effectiveDeck.isEmpty
    }

    private var bulkAddSection: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("一括入力")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("TAB区切り または CSV形式（表面,裏面）")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                TextEditor(text: $bulkText)
                    .frame(minHeight: 120)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
            }

            if !parsedCards.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("プレビュー（\(parsedCards.count)件）")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ForEach(Array(parsedCards.prefix(10).enumerated()), id: \.offset) { _, parsed in
                        HStack {
                            Text(parsed.front)
                                .font(.caption)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            Text(parsed.back)
                                .font(.caption)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 6))
                    }

                    if parsedCards.count > 10 {
                        Text("他 \(parsedCards.count - 10)件...")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Button {
                addBulkCards()
            } label: {
                Text("全て追加（\(parsedCards.count)件）")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(!parsedCards.isEmpty && !effectiveDeck.isEmpty ? AppColors.accent.gradient : Color.gray.gradient)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .disabled(parsedCards.isEmpty || effectiveDeck.isEmpty)
        }
    }

    private func addSingleCard() {
        let trimFront = front.trimmingCharacters(in: .whitespaces)
        let trimBack = back.trimmingCharacters(in: .whitespaces)
        guard !trimFront.isEmpty, !trimBack.isEmpty, !effectiveDeck.isEmpty else { return }

        let deckName = effectiveDeck
        let wasNew = isNewDeck
        store.addCard(
            front: trimFront,
            back: trimBack,
            deck: deckName,
            frontImage: frontImage,
            backImage: backImage
        )

        if wasNew && !selectedCourseId.isEmpty {
            store.addDeckToCourse(deckName, courseId: selectedCourseId)
        }

        front = ""
        back = ""
        frontImage = nil
        backImage = nil
        frontPickerItem = nil
        backPickerItem = nil
        toastMessage = "カードを追加しました"
        frontFocused = true

        if selectedDeck.isEmpty {
            selectedDeck = deckName
            newDeckName = ""
            selectedCourseId = ""
        }
    }

    private func addBulkCards() {
        guard !parsedCards.isEmpty, !effectiveDeck.isEmpty else { return }
        let deckName = effectiveDeck
        let wasNew = isNewDeck
        let cards = parsedCards.map { (front: $0.front, back: $0.back) }
        store.addCards(cards, deck: deckName)

        if wasNew && !selectedCourseId.isEmpty {
            store.addDeckToCourse(deckName, courseId: selectedCourseId)
        }

        toastMessage = "\(cards.count)件のカードを追加しました"
        bulkText = ""

        if selectedDeck.isEmpty {
            selectedDeck = deckName
            newDeckName = ""
            selectedCourseId = ""
        }
    }
}
