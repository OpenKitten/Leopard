import Lynx

extension Request : CustomDebugStringConvertible {
    /// Helps making Request easily readable
    public var debugDescription: String {
        return """
        \(self.method.string) \(self.path.string) HTTP/1.1
        \(self.headers)
        """
    }
}

extension Response : CustomDebugStringConvertible {
    ///
    public var debugDescription: String {
        return """
        HTTP/1.1 \(self.status)
        \(self.headers)
        """
    }
}
