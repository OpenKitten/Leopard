import Lynx

public class RoutedWebServer : WebsocketRouter {
    public func register(at path: [String], method: Method, handler: @escaping RequestHandler) {
        router.register(at: path, method: method, handler: handler)
    }
    
    public func handle(_ request: Request, for client: Client) {
        router.handle(request, for: client)
    }
    
    let server: HTTPServer
    let router = TrieRouter(startingTokensWith: 0x3a)
    
    public init() throws {
        self.server = try HTTPServer(handler: router.handle)
    }
    
    public func start() throws -> Never {
        try self.server.start()
    }
}

public final class SyncWebServer : RoutedWebServer, SyncRouter { }
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
    
    public func handle(_ request: Request, for client: Client) {
        router.handle(request, for: client)
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
    
    public func handle(_ request: Request, for client: Client) {
        router.handle(request, for: client)
    }
}
