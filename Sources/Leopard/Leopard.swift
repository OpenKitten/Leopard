import Lynx

/// A basic webserver with routing and websocket capabilities
public class RoutedWebServer : WebsocketRouter {
    /// Registers a route to the router
    public func register(at path: [String], method: Method, isFallbackHandler: Bool = false, handler: @escaping RequestHandler) {
        router.register(at: path, method: method, isFallbackHandler: isFallbackHandler, handler: handler)
    }
    
    /// Handles a request, passing it to the router
    public func handle(_ request: Request, for remote: HTTPRemote) {
        router.handle(request, for: remote)
    }
    
    /// The HTTPServer instance that serves this Leopard API/website
    let server: HTTPServer
    
    /// The HTTP Router that routes requests to the appropriate handler
    let router: TrieRouter
    
    /// Creates a new basic WebServer
    public init() throws {
        self.router = TrieRouter()
        self.server = try HTTPServer(handler: router.handle)
    }
    
    //// Creates a new RoutedWebServer from a config file
    ///
    /// Accepts custom HTTP and routing configurations
    public init(_ config: RoutingConfig) throws {
        let routeParameterTokenString = config.routeParameterToken
        let byte: UInt8?
        
        config: if let routeParameterTokenString = routeParameterTokenString {
            guard routeParameterTokenString.count == 1 else {
                byte = nil
                break config
            }
            
            guard let character = routeParameterTokenString.utf8.first else {
                throw LeopardConfigError.invalidRouteParameterToken(routeParameterTokenString)
            }
            
            byte = UInt8(character)
        } else {
            byte = 0x3a
        }
        
        var config = TrieRouter.Config()
        config.tokenByte = byte
        
        self.router = TrieRouter()
        
        if let config = config as? HTTPServerConfig {
            self.server = try HTTPServer(hostname: config.hostname, port: config.port, handler: router.handle)
        } else {
            self.server = try HTTPServer(handler: router.handle)
        }
    }
    
    /// Starts serving the site/API
    public func start() throws -> Never {
        try self.server.start()
    }
}

/// A WebServer with an asynchronous API
public final class WebServer : RoutedWebServer, AsyncRouter {
    /// All middlewares inbetween every registered route
    public let middlewares: [Middleware]
    
    /// Initializes with a sequence of middlewares and optional configuration file
    public init<S: Sequence>(middlewares: S, _ config: RoutingConfig? = nil) throws where S.Element : Middleware {
        self.middlewares = Array(middlewares)
        
        if let config = config {
            try super.init(config)
        } else {
            try super.init()
        }
    }
    
    /// Creates a new async webserver
    public override init() throws {
        self.middlewares = []
        try super.init()
    }
    
    /// Creates a new async webserver from a config file
    public override init(_ config: RoutingConfig) throws {
        middlewares = []
        try super.init(config)
    }
}
