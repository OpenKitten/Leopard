extension SyncRouter {
    public func grouped(_ path: String...) -> SyncRoutingGroup {
        return SyncRoutingGroup(path, pointingTo: self)
    }
    
    public func grouped<S: Sequence>(_ path: S) -> SyncRoutingGroup where S.Element == String {
        return SyncRoutingGroup(Array(path), pointingTo: self)
    }
    
    public func group<S: Sequence>(_ path: S, registering closure: ((SyncRoutingGroup) -> ())) where S.Element == String {
        closure(grouped(path))
    }
    
    public func group(path: String..., registering closure: ((SyncRoutingGroup) -> ())) {
        closure(grouped(path))
    }
}

public struct SyncRoutingGroup : SyncRouter {
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

