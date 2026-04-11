import SwiftUI
import UIKit
import PhotosUI

enum CardImageEditState {
    case unchanged
    case removed
    case new(UIImage)
}

struct CardEditSheet: View {
    @Environment(StudyDataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let card: Card

    @State private var front: String
    @State private var back: String

    @State private var frontImageState: CardImageEditState = .unchanged
    @State private var backImageState: CardImageEditState = .unchanged
    @State private var frontPickerItem: PhotosPickerItem?
    @State private var backPickerItem: PhotosPickerItem?
    @State private var frontPreview: UIImage?
    @State private var backPreview: UIImage?

    init(card: Card) {
        self.card = card
        _front = State(initialValue: card.front)
        _back = State(initialValue: card.back)
    }

    private var canSave: Bool {
        !front.trimmingCharacters(in: .whitespaces).isEmpty &&
        !back.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("表面（問題）") {
                    TextField("問題を入力", text: $front, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("表面の画像") {
                    imageEditRow(
                        preview: frontPreview,
                        pickerItem: $frontPickerItem,
                        onRemove: {
                            frontImageState = .removed
                            frontPreview = nil
                            frontPickerItem = nil
                        }
                    )
                }

                Section("裏面（答え）") {
                    TextField("答えを入力", text: $back, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("裏面の画像") {
                    imageEditRow(
                        preview: backPreview,
                        pickerItem: $backPickerItem,
                        onRemove: {
                            backImageState = .removed
                            backPreview = nil
                            backPickerItem = nil
                        }
                    )
                }
            }
            .navigationTitle("カードを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear { loadInitialPreviews() }
            .onChange(of: frontPickerItem) { _, newItem in
                loadPickedImage(item: newItem) { img in
                    if let img {
                        frontImageState = .new(img)
                        frontPreview = img
                    }
                }
            }
            .onChange(of: backPickerItem) { _, newItem in
                loadPickedImage(item: newItem) { img in
                    if let img {
                        backImageState = .new(img)
                        backPreview = img
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func imageEditRow(
        preview: UIImage?,
        pickerItem: Binding<PhotosPickerItem?>,
        onRemove: @escaping () -> Void
    ) -> some View {
        if let preview {
            VStack(alignment: .leading, spacing: 12) {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .clipShape(.rect(cornerRadius: 8))

                HStack(spacing: 12) {
                    PhotosPicker(selection: pickerItem, matching: .images) {
                        Label("変更", systemImage: "arrow.triangle.2.circlepath")
                            .font(.subheadline.weight(.medium))
                    }

                    Button(role: .destructive) {
                        onRemove()
                    } label: {
                        Label("削除", systemImage: "trash")
                            .font(.subheadline.weight(.medium))
                    }
                }
            }
            .padding(.vertical, 4)
        } else {
            PhotosPicker(selection: pickerItem, matching: .images) {
                Label("画像を追加", systemImage: "photo.badge.plus")
                    .font(.subheadline.weight(.medium))
            }
        }
    }

    private func loadInitialPreviews() {
        if case .unchanged = frontImageState,
           let name = card.imageFront,
           frontPreview == nil {
            frontPreview = ImageStorageService.loadImage(filename: name)
        }
        if case .unchanged = backImageState,
           let name = card.imageBack,
           backPreview == nil {
            backPreview = ImageStorageService.loadImage(filename: name)
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

    private func save() {
        var newFrontName = card.imageFront
        switch frontImageState {
        case .unchanged:
            break
        case .removed:
            ImageStorageService.deleteImage(cardId: card.id, side: .front)
            newFrontName = nil
        case .new(let img):
            newFrontName = ImageStorageService.saveImage(img, cardId: card.id, side: .front)
        }

        var newBackName = card.imageBack
        switch backImageState {
        case .unchanged:
            break
        case .removed:
            ImageStorageService.deleteImage(cardId: card.id, side: .back)
            newBackName = nil
        case .new(let img):
            newBackName = ImageStorageService.saveImage(img, cardId: card.id, side: .back)
        }

        store.updateCard(
            card,
            front: front.trimmingCharacters(in: .whitespaces),
            back: back.trimmingCharacters(in: .whitespaces),
            deck: card.deck,
            imageFront: newFrontName,
            imageBack: newBackName
        )
        dismiss()
    }
}
