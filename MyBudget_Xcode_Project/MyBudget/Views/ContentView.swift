import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var selectedCategory: ExpenseCategory?
    @State private var showAddExpense = false

    private var filteredExpenses: [Expense] {
        guard let selectedCategory else { return expenses }
        return expenses.filter { $0.category == selectedCategory.rawValue }
    }

    private var totalAmount: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                categoryFilter

                List {
                    if filteredExpenses.isEmpty {
                        ContentUnavailableView(
                            selectedCategory == nil ? "ხარჯები ჯერ არ გაქვთ" : "ხარჯები ვერ მოიძებნა",
                            systemImage: "tray",
                            description: Text(
                                selectedCategory == nil
                                ? "დაამატეთ თქვენი პირველი ხარჯი."
                                : "ამ კატეგორიაში ხარჯები არ არის."
                            )
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    } else {
                        Section {
                            ForEach(filteredExpenses) { expense in
                                ExpenseRowView(expense: expense)
                                    .listRowSeparator(.hidden)
                            }
                            .onDelete(perform: deleteExpenses)
                        } header: {
                            Text("ბოლო ხარჯები")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("ჩემი ბიუჯეტი")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 25))
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("ჯამური ხარჯი")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.8))

                    Text(totalAmount, format: .currency(code: "GEL"))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: "wallet.bifold.fill")
                    .font(.system(size: 35))
                    .foregroundStyle(.white)
            }

            HStack {
                Label("\(filteredExpenses.count) ჩანაწერი", systemImage: "list.bullet")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.85))

                Spacer()

                Text(selectedCategory?.rawValue ?? "ყველა კატეგორია")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [.blue, Color(red: 0.25, green: 0.35, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 18)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                filterButton(title: "ყველა", category: nil)

                ForEach(ExpenseCategory.allCases) { item in
                    filterButton(title: item.rawValue, category: item)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 12)
    }

    private func filterButton(title: String, category: ExpenseCategory?) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            selectedCategory = category
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    isSelected ? Color.blue : Color(uiColor: .secondarySystemGroupedBackground)
                )
                .foregroundStyle(isSelected ? .white : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredExpenses[index])
        }
        try? modelContext.save()
    }
}
