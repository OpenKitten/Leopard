import Dispatch
@_exported import Lynx
@_exported import Schrodinger

/// An synchronous HTTP Router
public protocol AsyncRouter : Router {
    /// All middlewares that requests get routed through
    var middlewares: [Middleware] { get }
}

extension AsyncRouter {
    /// No middlewares by default
    public var middlewares: [Middleware] {
        return []
    }
    
    /// Handles a request asynchronously using Schrodinger's futures
    public typealias AsyncHandler = ((Request) throws -> (Future<ResponseRepresentable>))
    
    /// Registers a new asynchronous handler at the provided path and method
    public func register(method: Lynx.Method, at path: [String], handler: @escaping AsyncHandler) {
        self.register(at: path, method: method)  { request, remote in
            do {
                guard self.middlewares.count > 0 else {
                    try handler(request).then { response in
                        do {
                            try remote.send(try response.assertSuccess().makeResponse())
                        } catch let error as Encodable & Error {
                            Application.logger?.log(error, level: .error)
                            remote.error(error)
                        } catch {
                            remote.error(error)
                        }
                    }
                    return
                }
                
                
                let finalHandler = self.middlewares.reversed().reduce({ (request: Request, remote: HTTPRemote) -> Void in
                    do {
                        try handler(request).then { response in
                            do {
                                try remote.send(try response.assertSuccess().makeResponse())
                            } catch let error as Encodable & Error {
                                Application.logger?.log(error, level: .error)
                                remote.error(error)
                            } catch {
                                remote.error(error)
                            }
                        }
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
    public func get(_ path: String..., handler: @escaping AsyncHandler) {
        self.register(method: .get, at: path, handler: handler)
    }
    
    /// Handles the path for PUT requests
    public func put(_ path: String..., handler: @escaping AsyncHandler) {
        self.register(method: .put, at: path, handler: handler)
    }
    
    /// Handles the path for POST requests
    public func post(_ path: String..., handler: @escaping AsyncHandler) {
        self.register(method: .post, at: path, handler: handler)
    }
    
    /// Handles the path for DELETE requests
    public func delete(_ path: String..., handler: @escaping AsyncHandler) {
        self.register(method: .delete, at: path, handler: handler)
    }
}
