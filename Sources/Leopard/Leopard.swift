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
        let routingToken = config.routingToken
        
        if let routingToken = routingToken {
            guard routingToken.utf8.count <= 1 else {
                throw LeopardConfigError.invalidRoutingToken(routingToken)
            }
        }
        
        self.router = TrieRouter(startingTokensWith: config.routingToken?.utf8.first)
        
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

/// A WebServer with a synchronous API
public final class SyncWebServer : RoutedWebServer, SyncRouter {
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
    
    /// Creates a new Sync WebServer
    public override init() throws {
        self.middlewares = []
        try super.init()
    }
    
    /// Creates a new SyncWebServer from a Config file
    public override init(_ config: RoutingConfig) throws {
        middlewares = []
        try super.init(config)
    }
}

public final class AsyncWebServer : RoutedWebServer, AsyncRouter {
    public let middlewares: [Middleware]
    
    public init<S: Sequence>(middlewares: S, _ config: RoutingConfig? = nil) throws where S.Element : Middleware {
        self.middlewares = Array(middlewares)
        
        if let config = config {
            try super.init(config)
        } else {
            try super.init()
        }
    }
    
    public override init() throws {
        self.middlewares = []
        try super.init()
    }
    
    public override init(_ config: RoutingConfig) throws {
        middlewares = []
        try super.init(config)
    }
}

public final class WebServer : RoutedWebServer {
    public var async: AsyncRouter {
        return AsyncWrapper(self)
    }
    
    public var sync: SyncRouter {
        return SyncWrapper(self)
    }
}

public final class SyncWrapper : SyncRouter {
    public func register(at path: [String], method: Method, handler: @escaping RequestHandler) {
        router.register(at: path, method: method, handler: handler)
    }
    
    let router: Router
    
    init(_ router: Router) {
        self.router = router
    }
    
    public func handle(_ request: Request, for remote: HTTPRemote) {
        router.handle(request, for: remote)
    }
}

public final class AsyncWrapper : AsyncRouter {
    public func register(at path: [String], method: Method, handler: @escaping RequestHandler) {
        router.register(at: path, method: method, handler: handler)
    }
    
    let router: Router
    
    init(_ router: Router) {
        self.router = router
    }
    
    public func handle(_ request: Request, for remote: HTTPRemote) {
        router.handle(request, for: remote)
    }
}
