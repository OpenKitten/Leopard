extension SyncRouter {
    /// Groups routes in the RoutingCollection at the provided path
    public func grouped(_ path: String...) -> SyncRoutingCollection {
        return SyncRoutingCollection(path, pointingTo: self)
    }
    
    /// Groups routes in the RoutingCollection at the provided path
    public func grouped<S: Sequence>(_ path: S) -> SyncRoutingCollection where S.Element == String {
        return SyncRoutingCollection(Array(path), pointingTo: self)
    }
    
    /// Groups routes in the RoutingCollection at the provided path
    ///
    /// Calls the provided closure with the route collection
    public func group<S: Sequence>(_ path: S, registering closure: ((SyncRoutingCollection) -> ())) where S.Element == String {
        closure(grouped(path))
    }
    
    /// Groups routes in the RoutingCollection at the provided path
    ///
    /// Calls the provided closure with the route collection
    public func group(path: String..., registering closure: ((SyncRoutingCollection) -> ())) {
        closure(grouped(path))
    }
}


public struct SyncRoutingCollection : SyncRouter {
    /// Handles an HTTP request using the provided router
    public func handle(_ request: Request, for remote: HTTPRemote) {
        router.handle(request, for: remote)
    }
    
    /// Registers a route grouped by the path
    public func register(at path: [String], method: Method, handler: @escaping RequestHandler) {
        router.register(at: self.path + path, method: method, handler: handler)
    }
    
    /// All paths components inbetween the level above and the groupes routes
    var path: [String]
    
    /// The router that routes are registered to
    let router: SyncRouter
    
    /// Creates a new routingCollection
    init(_ path: [String], pointingTo router: SyncRouter) {
        self.path = path
        self.router = router
    }
}

