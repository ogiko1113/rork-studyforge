import SwiftUI

struct BarData: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
}

struct SimpleBarChart: View {
    let data: [BarData]

    private var maxValue: Int {
        max(data.map(\.value).max() ?? 1, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(data) { item in
                VStack(spacing: 4) {
                    Text("\(item.value)")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.accent.gradient)
                        .frame(height: max(4, CGFloat(item.value) / CGFloat(maxValue) * 120))

                    Text(item.label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 160)
    }
}
