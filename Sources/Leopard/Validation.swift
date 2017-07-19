public protocol FormRequest : Decodable {
    func validate(loggingTo validationLogger: ValidationLogger) throws
}

extension FormRequest {
    public func assertValid() throws {
        let log = ValidationLogger()
        
        try self.validate(loggingTo: log)
        
        guard log.errors.count == 0 else {
            throw log
        }
    }
}

public class ValidationLogger : Error {
    public private(set) var errors: [Error] = []
    
    public func assert(_ error: Error?) {
        guard let error = error else {
            return
        }
        
        errors.append(error)
    }
}

public func ==<T : Equatable>(lhs: T, rhs: T) -> Error? {
    guard lhs == rhs else {
        return EqualityError(subject: lhs, problem: .notEqual, other: rhs)
    }
    
    return nil
}

public func !=<T : Equatable>(lhs: T, rhs: T) -> Error? {
    guard lhs == rhs else {
        return EqualityError(subject: lhs, problem: .equal, other: rhs)
    }
    
    return nil
}

public func <<T : Comparable>(lhs: T, rhs: T) -> Error? {
    guard lhs < rhs else {
        return ComparisonError(subject: lhs, problem: .notSmallEnough, other: rhs)
    }
    
    return nil
}

public func ><T : Comparable>(lhs: T, rhs: T) -> Error? {
    guard lhs > rhs else {
        return ComparisonError(subject: lhs, problem: .notLargeEnough, other: rhs)
    }
    
    return nil
}

public func <=<T : Comparable>(lhs: T, rhs: T) -> Error? {
    guard lhs <= rhs else {
        return ComparisonError(subject: lhs, problem: .tooLarge, other: rhs)
    }
    
    return nil
}

public func >=<T : Comparable>(lhs: T, rhs: T) -> Error? {
    guard lhs >= rhs else {
        return ComparisonError(subject: lhs, problem: .tooSmall, other: rhs)
    }
    
    return nil
}

public enum EqualityProblem {
    case equal
    case notEqual
}

public struct EqualityError<T: Equatable> : Error {
    var subject: T
    var problem: EqualityProblem
    var other: T
}

public enum ComparisonProblem {
    case tooSmall, tooLarge, notSmallEnough, notLargeEnough
}

public struct ComparisonError<T: Comparable> : Error {
    var subject: T
    var problem: ComparisonProblem
    var other: T
}
