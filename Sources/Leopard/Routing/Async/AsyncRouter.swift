import Dispatch
@_exported import Lynx
@_exported import Schrodinger

public protocol AsyncRouter : Router {
    var middlewares: [Middleware] { get }
}

extension AsyncRouter {
    public var middlewares: [Middleware] {
        return []
    }
    
    public typealias AsyncHandler = ((Request) throws -> (Future<ResponseRepresentable>))
    
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
    
    public func get(_ path: String..., handler: @escaping AsyncHandler) {
        self.register(method: .get, at: path, handler: handler)
    }
    
    public func put(_ path: String..., handler: @escaping AsyncHandler) {
        self.register(method: .put, at: path, handler: handler)
    }
    
    public func post(_ path: String..., handler: @escaping AsyncHandler) {
        self.register(method: .post, at: path, handler: handler)
    }
    
    public func delete(_ path: String..., handler: @escaping AsyncHandler) {
        self.register(method: .delete, at: path, handler: handler)
    }
}
