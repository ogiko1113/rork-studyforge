import SwiftUI

struct CourseDetailView: View {
    @Environment(StudyDataStore.self) private var store
    let courseId: String
    @State private var showAddDeckSheet: Bool = false
    @State private var showRenameAlert: Bool = false
    @State private var renameText: String = ""
    @State private var deckToRemove: String?
    @State private var showRemoveDeckAlert: Bool = false

    private var course: Course? {
        store.courses.first { $0.id == courseId }
    }

    private var decks: [StudyDataStore.DeckInfo] {
        guard let course else { return [] }
        return store.decksForCourse(course)
    }

    var body: some View {
        ScrollView {
            if decks.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity)
                    .padding(.top, 120)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(decks) { deck in
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
                                deckToRemove = deck.name
                                showRemoveDeckAlert = true
                            } label: {
                                Label("コースから外す", systemImage: "folder.badge.minus")
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(course?.name ?? "コース")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        renameText = course?.name ?? ""
                        showRenameAlert = true
                    } label: {
                        Label("コース名を変更", systemImage: "pencil")
                    }
                    Button {
                        showAddDeckSheet = true
                    } label: {
                        Label("デッキを追加", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .navigationDestination(for: String.self) { deckName in
            DeckDetailView(deckName: deckName)
        }
        .sheet(isPresented: $showAddDeckSheet) {
            AddDeckToCourseSheet(courseId: courseId)
        }
        .alert("コース名を変更", isPresented: $showRenameAlert) {
            TextField("コース名", text: $renameText)
            Button("保存") {
                if let course {
                    withAnimation { store.renameCourse(course, to: renameText) }
                }
            }
            Button("キャンセル", role: .cancel) {}
        }
        .alert("デッキをコースから外す", isPresented: $showRemoveDeckAlert) {
            Button("外す", role: .destructive) {
                if let deckName = deckToRemove {
                    withAnimation { store.removeDeckFromCourse(deckName, courseId: courseId) }
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("「\(deckToRemove ?? "")」をこのコースから外します。カードは削除されません。")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("デッキがありません")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            Text("既存のデッキをこのコースに追加しましょう")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showAddDeckSheet = true
            } label: {
                Text("デッキを追加")
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

struct AddDeckToCourseSheet: View {
    @Environment(StudyDataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let courseId: String

    private var availableDecks: [String] {
        let assigned = store.assignedDeckNames
        let courseDecks = store.courses.first { $0.id == courseId }?.deckNames ?? []
        return store.deckNames.filter { !assigned.contains($0) || courseDecks.contains($0) }
            .filter { !(courseDecks.contains($0)) }
    }

    var body: some View {
        NavigationStack {
            List {
                if availableDecks.isEmpty {
                    ContentUnavailableView(
                        "追加できるデッキがありません",
                        systemImage: "rectangle.stack",
                        description: Text("すべてのデッキが既にコースに割り当てられています")
                    )
                } else {
                    ForEach(availableDecks, id: \.self) { deckName in
                        Button {
                            withAnimation {
                                store.addDeckToCourse(deckName, courseId: courseId)
                            }
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(deckName)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text("\(store.cardsForDeck(deckName).count)枚のカード")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("デッキを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}
