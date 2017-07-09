import Lynx

extension Headers {
    public var host: String? {
        return String(self["Host"])
    }
}
