import Lynx

extension Headers {
    /// The requested host, can be used to serve multiple sites
    public var host: String? {
        return String(self["Host"])
    }
    
    /// A bearer authorization token extraction helper
    ///
    /// Returns `nil` if no bearer token is provided
    public var bearer: String? {
        guard var auth = String(self["Authorization"]), auth.hasPrefix("Bearer ") else {
            return nil
        }
        
        // "Bearer "
        auth.removeFirst(7)
        
        return auth
    }
}
