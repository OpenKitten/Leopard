import Lynx

extension Headers {
    /// The requested host, can be used to serve multiple sites
    public var host: String? {
        return String(self["Host"])
    }
}
