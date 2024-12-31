import Foundation

enum DataValidationError: Error {
    case invalidWeight
    case invalidBodyFat
    case invalidMuscleMass
    case invalidVisceralFat
    case invalidDate
}

extension DataValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidWeight:
            return "Please enter a valid weight. The weight must be greater than 0 and less than 500."
        case .invalidBodyFat:
            return "Please enter a valid body fat percentage (0-100)."
        case .invalidMuscleMass:
            return "Please enter a valid muscle mass percentage (0-100)."
        case .invalidVisceralFat:
            return "Please enter a valid visceral fat level (0-50)."
        case .invalidDate:
            return "Please enter a valid date."
        }
    }
}
