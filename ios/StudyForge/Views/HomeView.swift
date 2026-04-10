import SwiftUI

nonisolated enum HomeDestination: Hashable {
    case deck(String)
    case course(String)
}

struct HomeView: View {
    @Environment(StudyDataStore.self) private var store
    @State private var deckToDelete: String?
    @State private var showDeleteDeckAlert: Bool = false
    @State private var courseToDelete: Course?
    @State private var showDeleteCourseAlert: Bool = false
    @State private var showNewCourseAlert: Bool = false
    @State private var newCourseName: String = ""
    @State private var showMoveDeckSheet: Bool = false
    @State private var deckToMove: String?
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                if store.sortedDecks.isEmpty && store.courses.isEmpty {
                    emptyState
                        .frame(maxWidth: .infinity)
                        .padding(.top, 120)
                } else {
                    LazyVStack(spacing: 0) {
                        if !store.sortedCourses.isEmpty {
                            coursesSection
                        }
                        ungroupedSection
                    }
                    .padding(.top, 8)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("StudyForge")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newCourseName = ""
                        showNewCourseAlert = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .deck(let name):
                    DeckDetailView(deckName: name)
                case .course(let id):
                    CourseDetailView(courseId: id)
                }
            }
            .alert("新しいコース", isPresented: $showNewCourseAlert) {
                TextField("コース名", text: $newCourseName)
                Button("作成") {
                    withAnimation { store.addCourse(name: newCourseName) }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("新しいコースの名前を入力してください")
            }
            .alert("デッキを削除", isPresented: $showDeleteDeckAlert) {
                Button("削除", role: .destructive) {
                    if let deck = deckToDelete {
                        withAnimation { store.deleteDeck(deck) }
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("「\(deckToDelete ?? "")」のすべてのカードと学習履歴が削除されます。")
            }
            .alert("コースを削除", isPresented: $showDeleteCourseAlert) {
                Button("削除", role: .destructive) {
                    if let course = courseToDelete {
                        withAnimation { store.deleteCourse(course) }
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("「\(courseToDelete?.name ?? "")」を削除します。デッキとカードは削除されません。")
            }
            .sheet(isPresented: $showMoveDeckSheet) {
                if let deckName = deckToMove {
                    MoveDeckToCourseSheet(deckName: deckName)
                }
            }
        }
    }

    // MARK: - Courses Section

    private var coursesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("コース")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 16)
                .padding(.top, 4)

            ForEach(store.sortedCourses) { info in
                NavigationLink(value: HomeDestination.course(info.course.id)) {
                    CourseCardView(
                        courseName: info.course.name,
                        deckCount: info.deckCount,
                        totalDue: info.totalDue,
                        totalCards: info.totalCards
                    )
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(role: .destructive) {
                        courseToDelete = info.course
                        showDeleteCourseAlert = true
                    } label: {
                        Label("コースを削除", systemImage: "trash")
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Ungrouped Section

    private var ungroupedSection: some View {
        let ungrouped = store.ungroupedDecks
        return Group {
            if !ungrouped.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    if !store.sortedCourses.isEmpty {
                        Text("未分類")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                    }

                    ForEach(ungrouped) { deck in
                        NavigationLink(value: HomeDestination.deck(deck.name)) {
                            DeckCardView(
                                deckName: deck.name,
                                cardCount: deck.cardCount,
                                dueCount: deck.dueCount
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            if !store.courses.isEmpty {
                                Button {
                                    deckToMove = deck.name
                                    showMoveDeckSheet = true
                                } label: {
                                    Label("コースに移動", systemImage: "folder.badge.plus")
                                }
                            }
                            Button(role: .destructive) {
                                deckToDelete = deck.name
                                showDeleteDeckAlert = true
                            } label: {
                                Label("デッキを削除", systemImage: "trash")
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Empty State

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

struct MoveDeckToCourseSheet: View {
    @Environment(StudyDataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let deckName: String

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.courses) { course in
                    Button {
                        withAnimation {
                            store.addDeckToCourse(deckName, courseId: course.id)
                        }
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(course.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Text("\(course.deckNames.count)デッキ")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "folder.badge.plus")
                                .foregroundStyle(AppColors.accent)
                        }
                    }
                }
            }
            .navigationTitle("コースに移動")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}
