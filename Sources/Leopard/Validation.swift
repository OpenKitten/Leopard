public protocol FormRequest : Decodable {
    func validate(loggingTo validator: Validator) throws
}

extension FormRequest {
    public func assertValid() throws {
        let log = Validator()
        
        try self.validate(loggingTo: log)
        
        guard log.errors.count == 0 else {
            throw log
        }
    }
}

public protocol EncodableError : Error, Encodable {}

public class ErrorMessage : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(message)
    }
    
    let error: EncodableError
    var message: String?
    
    public func or(_ message: String) {
        self.message = message
    }
    
    public init(for error: EncodableError) {
        self.error = error
    }
}

extension Optional where Wrapped == ErrorMessage {
    public func or(_ message: String) {
        self?.or(message)
    }
}

public class Validator : EncodableError {
    public private(set) var errors: [ErrorMessage] = []
    
    @discardableResult
    public func assertNil<T : Encodable>(_ value: T?) -> ErrorMessage? {
        guard let value = value else {
            return nil
        }
        
        let message = ErrorMessage(for: ValidatorError.notNil(value))
        
        errors.append(message)
        
        return message
    }
    
    @discardableResult
    public func assertNotNil<T : Encodable>(_ value: T?) -> ErrorMessage? {
        guard value == nil else {
            return nil
        }
        
        let message = ErrorMessage(for: ValidatorError.isNil(T.self))
        
        errors.append(message)
        
        return message
    }
    
    @discardableResult
    public func assert(_ error: EncodableError?) -> ErrorMessage? {
        guard let error = error else {
            return nil
        }
        
        let message = ErrorMessage(for: error)
        
        errors.append(message)
        
        return message
    }
}

public func ==<T : Equatable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs == rhs else {
        return EqualityError(subject: lhs, problem: .notEqual, other: rhs)
    }
    
    return nil
}

public func !=<T : Equatable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs == rhs else {
        return EqualityError(subject: lhs, problem: .equal, other: rhs)
    }
    
    return nil
}

public func <<T : Comparable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs < rhs else {
        return ComparisonError(subject: lhs, problem: .notSmallEnough, other: rhs)
    }
    
    return nil
}

public func ><T : Comparable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs > rhs else {
        return ComparisonError(subject: lhs, problem: .notLargeEnough, other: rhs)
    }
    
    return nil
}

public func <=<T : Comparable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs <= rhs else {
        return ComparisonError(subject: lhs, problem: .tooLarge, other: rhs)
    }
    
    return nil
}

public func >=<T : Comparable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs >= rhs else {
        return ComparisonError(subject: lhs, problem: .tooSmall, other: rhs)
    }
    
    return nil
}

public enum ValidatorError<T : Encodable> : EncodableError {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .notNil(let value):
            try value.encode(to: encoder)
        case .isNil(_):
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
    
    case isNil(T.Type)
    case notNil(T)
}

public enum EqualityProblem : String, Encodable {
    case equal
    case notEqual
}

public struct EqualityError<T: Equatable & Encodable> : EncodableError {
    var subject: T
    var problem: EqualityProblem
    var other: T
}

public enum ComparisonProblem : String, Encodable {
    case tooSmall, tooLarge, notSmallEnough, notLargeEnough
}

public struct ComparisonError<T: Comparable & Encodable> : EncodableError {
    var subject: T
    var problem: ComparisonProblem
    var other: T
}
