extension AsyncRouter {
    public func grouped(_ path: String...) -> AsyncRoutingGroup {
        return AsyncRoutingGroup(path, pointingTo: self)
    }
    
    public func grouped<S: Sequence>(_ path: S) -> AsyncRoutingGroup where S.Element == String {
        return AsyncRoutingGroup(Array(path), pointingTo: self)
    }
    
    public func group<S: Sequence>(_ path: S, registering closure: ((AsyncRoutingGroup) -> ())) where S.Element == String {
        closure(grouped(path))
    }
    
    public func group(path: String..., registering closure: ((AsyncRoutingGroup) -> ())) {
        closure(grouped(path))
    }
}

public struct AsyncRoutingGroup : AsyncRouter {
    public func handle(_ request: Request, for client: Client) {
        router.handle(request, for: client)
    }
    
    public func register(at path: [String], method: Method, handler: @escaping RequestHandler) {
        router.register(at: self.path + path, method: method, handler: handler)
    }
    
    var path: [String]
    let router: AsyncRouter
    
    init(_ path: [String], pointingTo router: AsyncRouter) {
        self.path = path
        self.router = router
    }
}

