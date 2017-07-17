open class Application {
    open var server: RoutedWebServer
    
    open static var logger: Logger? = nil
    
    public init(server: RoutedWebServer) {
        self.server = server
    }
    
    open func start() throws -> Never {
        try server.start()
    }
}
