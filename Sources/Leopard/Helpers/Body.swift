import Cheetah

/// Helpers for reading the body
extension BodyRepresentable {
    /// Attempts to read the body as a JSONObject
    public var jsonObject: JSONObject? {
        guard let buffer = try? self.makeBody().buffer else {
            return nil
        }
        
        return try? JSONObject(from: Array(buffer))
    }
    
    /// Attempts to read the body as a UTF-8 String
    public var string: String? {
        guard let buffer = try? self.makeBody().buffer else {
            return nil
        }
        
        return String(bytes: buffer, encoding: .utf8)
    }
}

/// Serializes this JSONObject to a body
extension JSONObject : BodyRepresentable {
    public func makeBody() throws -> Body {
        return Body(self.serialize())
    }
}

/// Serializes this JSONArray to a body
extension JSONArray : BodyRepresentable {
    public func makeBody() throws -> Body {
        return Body(self.serialize())
    }
}
