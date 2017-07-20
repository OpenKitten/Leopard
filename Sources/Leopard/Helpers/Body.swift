import Cheetah

extension BodyRepresentable {
    public var jsonObject: JSONObject? {
        guard let buffer = try? self.makeBody().buffer else {
            return nil
        }
        
        return try? JSONObject(from: Array(buffer))
    }
    
    public var string: String? {
        guard let buffer = try? self.makeBody().buffer else {
            return nil
        }
        
        return String(bytes: buffer, encoding: .utf8)
    }
}

extension JSONObject : BodyRepresentable {
    public func makeBody() throws -> Body {
        return Body(self.serialize())
    }
}

extension JSONArray : BodyRepresentable {
    public func makeBody() throws -> Body {
        return Body(self.serialize())
    }
}
