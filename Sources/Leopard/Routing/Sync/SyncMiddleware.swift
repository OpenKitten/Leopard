extension SyncRouter {
    /// All routes registered in this group will run through the provided middlewares first
    public func grouped<S: Sequence>(_ middlewares: S) -> SyncRoutingGroup where S.Element == Middleware {
        return SyncRoutingGroup(Array(middlewares), pointingTo: self)
    }
    
    /// All routes registered in this group will run through the provided middlewares first
    public func grouped(_ middlewares: Middleware...) -> SyncRoutingGroup {
        return SyncRoutingGroup(middlewares, pointingTo: self)
    }
}

/// A routing group that handles requests asynchronously
///
/// Requests pass through the middlewares first
public struct SyncRoutingGroup : SyncRouter {
    /// Handles the request
    public func handle(_ request: Request, for remote: HTTPRemote) {
        router.handle(request, for: remote)
    }
    
    /// Registers a route grouped under the middlewares
    public func register(at path: [String], method: Method, handler: @escaping RequestHandler) {
        guard middlewares.count > 0 else {
            router.register(at: path, method: method, handler: handler)
            return
        }
        
        router.register(at: path, method: method) { request, remote in
            let responder = self.middlewares.reduce(handler, { responder, middleware in
                return { request, remote in
                    return middleware.handle(request, for: remote, chainingTo: responder)
                }
            })
            
            responder(request, remote)
        }
    }
    
    /// All middlewares that will be called in the array order before executing the handler
    public let middlewares: [Middleware]
    
    /// The router that routes are registered to
    let router: SyncRouter
    
    /// Creates a new routing group with middlewares to group by
    public init(_ middlewares: [Middleware], pointingTo router: SyncRouter) {
        self.middlewares = middlewares.reversed()
        self.router = router
    }
}
