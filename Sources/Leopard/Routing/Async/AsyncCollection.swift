import Lynx

extension AsyncRouter {
    public func grouped(_ path: String...) -> AsyncRoutingCollection {
        return AsyncRoutingCollection(path, pointingTo: self)
    }
    
    public func grouped<S: Sequence>(_ path: S) -> AsyncRoutingCollection where S.Element == String {
        return AsyncRoutingCollection(Array(path), pointingTo: self)
    }
    
    public func group<S: Sequence>(_ path: S, registering closure: ((AsyncRoutingCollection) -> ())) where S.Element == String {
        closure(grouped(path))
    }
    
    public func group(path: String..., registering closure: ((AsyncRoutingCollection) -> ())) {
        closure(grouped(path))
    }
}

public struct AsyncRoutingCollection : AsyncRouter {
    public func handle(_ request: Request, for remote: HTTPRemote) {
        router.handle(request, for: remote)
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

