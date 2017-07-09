import Lynx

/// Something that can be crafted from a path component
public protocol PathComponentInitializable {
    init?(from string: String) throws
}

/// Makes a string craftable from a path component
extension String : PathComponentInitializable {
    /// Initializes a string from a path component
    public init?(from string: String) throws {
        self = string
    }
}

/// Error that gets thrown when extracting a path component into an entity isn't possible
public struct InvalidExtractionError : Error {}

extension Request {
    /// Extracts the string on the token's position
    public func extract(from token: String) throws -> String {
        guard let value = self.url.tokens[token] else {
            throw InvalidExtractionError()
        }
        
        return value
    }
    
    /// Extracts a type from a PathComponent
    public func extract<PCI: PathComponentInitializable>(_ initializable: PCI.Type, from token: String) throws -> PCI? {
        guard let value = self.url.tokens[token] else {
            throw InvalidExtractionError()
        }
        
        return try PCI(from: value)
    }
}
