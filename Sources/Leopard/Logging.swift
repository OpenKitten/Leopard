public enum LogLevel {
    case verbose, debug, info, warning, error
}

public protocol Logger {
    func log(_ entity: Encodable, level: LogLevel)
}
