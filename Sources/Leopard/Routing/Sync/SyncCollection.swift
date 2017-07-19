extension SyncRouter {
    public func grouped(_ path: String...) -> SyncRoutingCollection {
        return SyncRoutingCollection(path, pointingTo: self)
    }
    
    public func grouped<S: Sequence>(_ path: S) -> SyncRoutingCollection where S.Element == String {
        return SyncRoutingCollection(Array(path), pointingTo: self)
    }
    
    public func group<S: Sequence>(_ path: S, registering closure: ((SyncRoutingCollection) -> ())) where S.Element == String {
        closure(grouped(path))
    }
    
    public func group(path: String..., registering closure: ((SyncRoutingCollection) -> ())) {
        closure(grouped(path))
    }
}

public struct SyncRoutingCollection : SyncRouter {
    public func handle(_ request: Request, for remote: HTTPRemote) {
        router.handle(request, for: remote)
    }
    
    public func register(at path: [String], method: Method, handler: @escaping RequestHandler) {
        router.register(at: self.path + path, method: method, handler: handler)
    }
    
    var path: [String]
    let router: SyncRouter
    
    init(_ path: [String], pointingTo router: SyncRouter) {
        self.path = path
        self.router = router
    }
}

