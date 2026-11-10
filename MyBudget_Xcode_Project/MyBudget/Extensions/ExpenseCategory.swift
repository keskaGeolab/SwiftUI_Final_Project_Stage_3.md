import Foundation

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food = "საკვები"
    case transport = "ტრანსპორტი"
    case entertainment = "გართობა"
    case other = "სხვა"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .entertainment: return "gamecontroller.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}
