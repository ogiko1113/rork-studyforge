import SwiftUI

struct ReviewGradeButton: View {
    let label: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.gradient)
            .clipShape(.rect(cornerRadius: 10))
        }
    }
}
