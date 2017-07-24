import Lynx
import Dispatch

/// A synchronous HTTP Router
public protocol SyncRouter : Router {
    /// All middlewares that requests get routed through
    var middlewares: [Middleware] { get }
}

extension SyncRouter {
    /// No middlewares by default
    public var middlewares: [Middleware] {
        return []
    }
    
    /// Registers a new synchronous handlers at the provided path and method
    fileprivate func register(_ path: [String], method: Lynx.Method, handler: @escaping ((Request) throws -> (ResponseRepresentable))) {
        self.register(at: path, method: method) { request, remote in
            do {
                guard self.middlewares.count > 0 else {
                    let response = try handler(request)
                    
                    try remote.send(try response.makeResponse())
                    return
                }
                
                let finalHandler = self.middlewares.reversed().reduce({ (request: Request, remote: HTTPRemote) -> Void in
                    do {
                        let response = try handler(request)
                        try remote.send(try response.makeResponse())
                    } catch let error as Encodable & Error {
                        Application.logger?.log(error, level: .error)
                        remote.error(error)
                    } catch {
                        remote.error(error)
                    }
                } as RequestHandler) { (handler: @escaping RequestHandler, middleware: Middleware) in
                    return { request, remote in
                        middleware.handle(request, for: remote, chainingTo: handler)
                    }
                }
                
                finalHandler(request, remote)
            } catch let error as Encodable & Error {
                Application.logger?.log(error, level: .error)
                remote.error(error)
            } catch {
                remote.error(error)
            }
        }
    }
    
    /// Handles the path for GET requests
    public func get(_ path: String..., handler: @escaping ((Request) throws -> (ResponseRepresentable))) {
        self.register(path, method: .get, handler: handler)
    }
    
    /// Handles the path for PUT requests
    public func put(_ path: String..., handler: @escaping ((Request) throws -> (ResponseRepresentable))) {
        self.register(path, method: .put, handler: handler)
    }
    
    /// Handles the path for POST requests
    public func post(_ path: String..., handler: @escaping ((Request) throws -> (ResponseRepresentable))) {
        self.register(path, method: .post, handler: handler)
    }
    
    /// Handles the path for DELETE requests
    public func delete(_ path: String..., handler: @escaping ((Request) throws -> (ResponseRepresentable))) {
        self.register(path, method: .delete, handler: handler)
    }
}
