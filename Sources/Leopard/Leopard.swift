import Lynx

public class RoutedWebServer : WebsocketRouter {
    public func register(at path: [String], method: Method, handler: @escaping RequestHandler) {
        router.register(at: path, method: method, handler: handler)
    }
    
    public func handle(_ request: Request, for remote: HTTPRemote) {
        router.handle(request, for: remote)
    }
    
    let server: HTTPServer
    let router: TrieRouter
    
    public init() throws {
        self.router = TrieRouter(startingTokensWith: 0x3a)
        self.server = try HTTPServer(handler: router.handle)
    }
    
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
    
    public func start() throws -> Never {
        try self.server.start()
    }
}

public final class SyncWebServer : RoutedWebServer, SyncRouter {
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

public final class AsyncWebServer : RoutedWebServer, AsyncRouter { }

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
