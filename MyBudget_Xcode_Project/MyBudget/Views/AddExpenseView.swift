import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var amount = ""
    @State private var category: ExpenseCategory = .food
    @State private var date = Date()
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("ხარჯის ინფორმაცია") {
                    TextField("მაგ. სადილი", text: $title)

                    HStack {
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                        Text("₾")
                            .foregroundStyle(.secondary)
                    }

                    Picker("კატეგორია", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { item in
                            Label(item.rawValue, systemImage: item.icon).tag(item)
                        }
                    }

                    DatePicker("თარიღი", selection: $date, displayedComponents: .date)
                }

                Section {
                    Button(action: saveExpense) {
                        HStack {
                            Spacer()
                            Text("შენახვა").fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .foregroundStyle(.white)
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("ახალი ხარჯი")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("გაუქმება") { dismiss() }
                }
            }
            .alert("შეცდომა", isPresented: $showError) {
                Button("კარგი", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func saveExpense() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")

        guard !trimmedTitle.isEmpty else {
            showValidationError("გთხოვთ, შეიყვანოთ ხარჯის დასახელება.")
            return
        }

        guard let value = Double(normalizedAmount), value.isFinite, value > 0 else {
            showValidationError("თანხა უნდა იყოს ნულზე მეტი და სწორი რიცხვი.")
            return
        }

        modelContext.insert(Expense(
            title: trimmedTitle,
            amount: value,
            category: category.rawValue,
            date: date
        ))

        do {
            try modelContext.save()
            dismiss()
        } catch {
            showValidationError("ხარჯის შენახვა ვერ მოხერხდა.")
        }
    }

    private func showValidationError(_ message: String) {
        errorMessage = message
        showError = true
    }
}
