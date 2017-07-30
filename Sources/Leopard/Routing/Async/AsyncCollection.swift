import Lynx

extension AsyncRouter {
    /// Groups routes in the RoutingCollection at the provided path
    public func grouped(_ path: String...) -> AsyncRoutingCollection {
        return AsyncRoutingCollection(path, pointingTo: self)
    }
    
    /// Groups routes in the RoutingCollection at the provided path
    public func grouped<S: Sequence>(_ path: S) -> AsyncRoutingCollection where S.Element == String {
        return AsyncRoutingCollection(Array(path), pointingTo: self)
    }
    
    /// Groups routes in the RoutingCollection at the provided path
    ///
    /// Calls the provided closure with the route collection
    public func group<S: Sequence>(_ path: S, registering closure: ((AsyncRoutingCollection) -> ())) where S.Element == String {
        closure(grouped(path))
    }
    
    /// Groups routes in the RoutingCollection at the provided path
    ///
    /// Calls the provided closure with the route collection
    public func group(path: String..., registering closure: ((AsyncRoutingCollection) -> ())) {
        closure(grouped(path))
    }
}

public struct AsyncRoutingCollection : AsyncRouter {
    /// Handles an HTTP request using the provided router
    public func handle(_ request: Request, for remote: HTTPRemote) {
        router.handle(request, for: remote)
    }
    
    /// Registers a route grouped by the path
    public func register(at path: [String], method: Method, isFallbackHandler: Bool = false, handler: @escaping RequestHandler) {
        router.register(at: self.path + path, method: method, isFallbackHandler: isFallbackHandler, handler: handler)
    }
    
    /// All paths components inbetween the level above and the groupes routes
    var path: [String]
    
    /// The router that routes are registered to
    let router: AsyncRouter
    
    /// Creates a new routingCollection
    init(_ path: [String], pointingTo router: AsyncRouter) {
        self.path = path
        self.router = router
    }
}

