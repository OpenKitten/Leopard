import Lynx
import Dispatch

public protocol SyncRouter : Router {
    var middlewares: [SyncMiddleware] { get }
}

/// Vapor API
extension SyncRouter {
    public var middlewares: [SyncMiddleware] {
        return []
    }
    
    /// Registers a route
    fileprivate func register(_ path: [String], method: Lynx.Method, handler: @escaping ((Request) throws -> (ResponseRepresentable))) {
        self.register(at: path, method: method) { request, remote in
            do {
                guard middlewares.count > 0 else {
                    let response = try handler(request)
                    
                    try remote.send(try response.makeResponse())
                }
                
                middlewares
            } catch let error as Encodable & Error {
                Application.logger?.log(error, level: .error)
                remote.error(error)
            } catch {
                remote.error(error)
            }
        }
    }
    
    /// Registers a get route
    public func get(_ path: String..., handler: @escaping ((Request) throws -> (ResponseRepresentable))) {
        self.register(path, method: .get, handler: handler)
    }
    
    /// Registers a put route
    public func put(_ path: String..., handler: @escaping ((Request) throws -> (ResponseRepresentable))) {
        self.register(path, method: .put, handler: handler)
    }
    
    /// Registers a post route
    public func post(_ path: String..., handler: @escaping ((Request) throws -> (ResponseRepresentable))) {
        self.register(path, method: .post, handler: handler)
    }
    
    /// Registers a delete route
    public func delete(_ path: String..., handler: @escaping ((Request) throws -> (ResponseRepresentable))) {
        self.register(path, method: .delete, handler: handler)
    }
}
