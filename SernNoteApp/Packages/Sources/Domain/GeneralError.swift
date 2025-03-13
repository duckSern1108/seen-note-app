import Foundation

public enum GeneralError: Error {
    case unexpected
    case localError(msg: String)
}
