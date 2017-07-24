/// A client request that is validatable using a validator
public protocol Validatable : Decodable {
    /// Validates the current entity to a validator
    ///
    /// Does not throw an error when validation fails
    ///
    /// - throws: When a validation step failed, like fetching entities from the database
    func validate(loggingTo validator: Validator) throws
}

extension Validatable {
    /// Asserts the successful validation of the input
    ///
    /// - throws: An error when validation fails at one or more points
    public func assertValid() throws {
        let log = Validator()
        
        try self.validate(loggingTo: log)
        
        guard log.errors.count == 0 else {
            throw log
        }
    }
}

/// An error that occurs when encoding fails
public protocol EncodableError : Error, Encodable {}

/// An error message
public class ErrorMessage : Encodable {
    /// Encodes this error message
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(message)
    }
    
    /// The validation error that this error message represetns
    let error: EncodableError
    
    /// The message coupled with this specific error
    var message: Encodable?
    
    /// Sets the message associated with this error
    public func or(_ message: Encodable) {
        self.message = message
    }
    
    /// Creates a new error message from an error
    public init(for error: EncodableError) {
        self.error = error
    }
}

extension Optional where Wrapped == ErrorMessage {
    /// Sets the erorr message if this optional contains an error
    public func or(_ message: Encodable) {
        self?.or(message)
    }
}

/// A validator that keeps track of all validation errors
public class Validator : EncodableError {
    /// A list of all found validation errros
    public private(set) var errors: [ErrorMessage] = []
    
    /// Asserts that the contents of this variable is `nil`
    @discardableResult
    public func assertNil<T : Encodable>(_ value: T?) -> ErrorMessage? {
        guard let value = value else {
            return nil
        }
        
        let message = ErrorMessage(for: NilValidatorError.notNil(value))
        
        errors.append(message)
        
        return message
    }
    
    /// Asserts that the contents of this variable is not `nil`
    @discardableResult
    public func assertNotNil<T : Encodable>(_ value: T?) -> ErrorMessage? {
        guard value == nil else {
            return nil
        }
        
        let message = ErrorMessage(for: NilValidatorError.isNil(T.self))
        
        errors.append(message)
        
        return message
    }
    
    /// Asserts no error occurred
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

/// Checks if two values are equal.
///
/// Returns `nil` if the two values are equal, returns the error otherwise
public func ==<T : Equatable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs == rhs else {
        return EqualityError(subject: lhs, problem: .notEqual, other: rhs)
    }
    
    return nil
}

/// Checks if two values are not equal.
///
/// Returns `nil` if the two values are not equal occurred, returns the error otherwise
public func !=<T : Equatable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs == rhs else {
        return EqualityError(subject: lhs, problem: .equal, other: rhs)
    }
    
    return nil
}

/// Checks if the left hand side is smaller than the right hand side.
///
/// `3 < 4`
///
/// Returns `nil` if the `lhs` is smaller than the `rhs`, returns the error otherwise
public func <<T : Comparable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs < rhs else {
        return ComparisonError(subject: lhs, problem: .notSmallEnough, other: rhs)
    }
    
    return nil
}

/// Checks if the left hand side is larger than the right hand side.
///
/// `3 < 4`
///
/// Returns `nil` if the `lhs` is larger than the `rhs`, returns the error otherwise
public func ><T : Comparable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs > rhs else {
        return ComparisonError(subject: lhs, problem: .notLargeEnough, other: rhs)
    }
    
    return nil
}

/// Checks if the left hand side is samller or equal to the right hand side.
///
/// `3 < 4`
///
/// Returns `nil` if the `lhs` is larger or equal to the `rhs`, returns the error otherwise
public func <=<T : Comparable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs <= rhs else {
        return ComparisonError(subject: lhs, problem: .tooLarge, other: rhs)
    }
    
    return nil
}

/// Checks if the left hand side is larger than the right hand side.
///
/// `3 < 4`
///
/// Returns `nil` if the `lhs` is larger than the `rhs`, returns the error otherwise
public func >=<T : Comparable & Encodable>(lhs: T, rhs: T) -> EncodableError? {
    guard lhs >= rhs else {
        return ComparisonError(subject: lhs, problem: .tooSmall, other: rhs)
    }
    
    return nil
}

/// Nil validation errors
public enum NilValidatorError<T : Encodable> : EncodableError {
    /// Encodes the error
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .notNil(let value):
            try value.encode(to: encoder)
        case .isNil(_):
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
    
    /// The value of the given type is `nil`, even though it must contain a value
    case isNil(T.Type)
    
    /// The given value is not `nil` and contains the following value even though it must be `nil`
    case notNil(T)
}

/// Equality validation problems
public enum EqualityProblem : String, Encodable {
    /// Both values are equal while they mustn't be
    case equal
    
    /// Both values are not equal while they must be
    case notEqual
}

/// The two entities are not matching the equality requirement
public struct EqualityError<T: Equatable & Encodable> : EncodableError {
    /// The subject to compare, or, `lhs`
    var subject: T
    
    /// The problem in this equation. Contains the problem, not the requirement.
    var problem: EqualityProblem
    
    /// The other entity. The subject will be compared to this entity.
    ///
    /// Otherwise known as the `rhs`
    var other: T
}

/// Comparison failed
public enum ComparisonProblem : String, Encodable {
    /// The `lhs` subject was too small. It must be equal to or larger than the other entity.
    case tooSmall
    
    /// The `lhs` subject was too large. It must be equal to or smaller than the other entity.
    case tooLarge
    
    /// The `lhs` subject was too large, it must be smaller than the other entity
    case notSmallEnough
    
    /// The `lhs` subject was too small, it must be larger than the other entity
    case notLargeEnough
}

/// Comparison error. The `lhs` was not the right value compared to the `rhs`
public struct ComparisonError<T: Comparable & Encodable> : EncodableError {
    /// The subject to compare, or, `lhs`
    var subject: T
    
    /// The problem that occurred
    var problem: ComparisonProblem
    
    /// The other entity to compare the subject with, or, `rhs`
    var other: T
}
