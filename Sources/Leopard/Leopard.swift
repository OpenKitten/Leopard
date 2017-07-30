import Lynx

/// A basic webserver with routing and websocket capabilities
public class RoutedWebServer : WebsocketRouter {
    /// Registers a route to the router
    public func register(at path: [String], method: Method, handler: @escaping RequestHandler) {
        router.register(at: path, method: method, handler: handler)
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
        self.router = TrieRouter(startingTokensWith: 0x3a)
        self.server = try HTTPServer(handler: router.handle)
    }
    
    //// Creates a new RoutedWebServer from a config file
    ///
    /// Accepts custom HTTP and routing configurations
    public init(_ config: RoutingConfig) throws {
        let routeParameterToken = config.routeParameterToken
        let splitPaths = config.splitPaths ?? true
        
        if let routeParameterToken = routeParameterToken {
            guard routeParameterToken.utf8.count <= 1 else {
                throw LeopardConfigError.invalidRouteParameterToken(routeParameterToken)
            }
        }
        
        self.router = TrieRouter(startingTokensWith: config.routeParameterToken?.utf8.first, splittingPaths: splitPaths)
        
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
