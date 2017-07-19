extension SyncRouter {
    public func grouped<S: Sequence>(_ middlewares: S) -> SyncRoutingGroup where S.Element == SyncMiddleware {
        return SyncRoutingGroup(Array(middlewares), pointingTo: self)
    }
    
    public func grouped(_ middlewares: SyncMiddleware...) -> SyncRoutingGroup {
        return SyncRoutingGroup(middlewares, pointingTo: self)
    }
}

public struct SyncRoutingGroup : SyncRouter {
    public func handle(_ request: Request, for remote: HTTPRemote) {
        router.handle(request, for: remote)
    }
    
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
    
    public let middlewares: [SyncMiddleware]
    let router: SyncRouter
    
    public init(_ middlewares: [SyncMiddleware], pointingTo router: SyncRouter) {
        self.middlewares = middlewares.reversed()
        self.router = router
    }
}
