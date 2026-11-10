import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense

    private var category: ExpenseCategory {
        ExpenseCategory(rawValue: expense.category) ?? .other
    }

    private var categoryColor: Color {
        switch category {
        case .food: return .orange
        case .transport: return .blue
        case .entertainment: return .purple
        case .other: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: category.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(categoryColor)
                .frame(width: 48, height: 48)
                .background(categoryColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 5) {
                Text(expense.title)
                    .font(.system(size: 16, weight: .semibold))

                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Text(expense.category)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(categoryColor)
            }

            Spacer()

            Text(expense.amount, format: .currency(code: "GEL"))
                .font(.system(size: 16, weight: .bold))
        }
        .padding(.vertical, 8)
    }
}
