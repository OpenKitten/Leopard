import Lynx

extension Headers {
    /// The requested host, can be used to serve multiple sites
    public var host: String? {
        return String(self["Host"])
    }
    
    public var bearer: String? {
        guard var auth = String(self["Authorization"]), auth.hasPrefix("Bearer ") else {
            return nil
        }
        
        // "Bearer "
        auth.removeFirst(7)
        
        return auth
    }
}

extension Request : CustomDebugStringConvertible {
    public var debugDescription: String {
        return """
        \(self.method.string) \(self.url.string) HTTP/1.1
        \(self.headers)
        """
    }
}
