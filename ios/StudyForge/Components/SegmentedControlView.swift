import SwiftUI

struct SegmentedControlView: View {
    @Binding var selection: Int
    let titles: [String]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                Button {
                    withAnimation(.snappy) {
                        selection = index
                    }
                } label: {
                    Text(title)
                        .font(.subheadline.weight(selection == index ? .semibold : .regular))
                        .foregroundStyle(selection == index ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selection == index ? AppColors.accent : Color.clear)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
        }
        .padding(3)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}
