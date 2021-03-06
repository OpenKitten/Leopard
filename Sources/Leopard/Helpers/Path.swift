import Lynx

/// Something that can be crafted from a path component
public protocol PathComponentExtracting {
    associatedtype Extracted
    
    static func extract(from string: String) throws -> Extracted?
}

/// Makes a string craftable from a path component
extension String : PathComponentExtracting {
    /// Initializes a string from a path component
    public static func extract(from string: String) throws -> String? {
        return string
    }
}

/// Error that gets thrown when extracting a path component into an entity isn't possible
public struct InvalidExtractionError : Error {}

extension Request {
    /// Extracts the string on the token's position
    public func extract(from token: String) throws -> String {
        guard let value = self.path.tokens[token] else {
            throw InvalidExtractionError()
        }
        
        return value
    }
    
    /// Extracts a type from a PathComponent
    public func extract<PCI: PathComponentExtracting>(_ initializable: PCI.Type, from token: String) throws -> PCI.Extracted? {
        guard let value = self.path.tokens[token] else {
            throw InvalidExtractionError()
        }
        
        return try PCI.extract(from: value)
    }
}
