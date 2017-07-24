/// A basic, extensible application
///
/// Contains a webserver and may contain a logger
///
/// Used as a static global entity
open class Application {
    /// The routed webserver
    ///
    /// Combination of a router and a webserver
    ///
    /// Does not define sync and async API helpers yet
    open var server: RoutedWebServer
    
    /// The log destination that logs are sent to
    open static var logger: Logger? = nil
    
    /// Creates a new application from a routed web server
    public init(server: RoutedWebServer) {
        self.server = server
    }
    
    /// Starts the webserver, can be overriden to include startup actions
    open func start() throws -> Never {
        try server.start()
    }
}
