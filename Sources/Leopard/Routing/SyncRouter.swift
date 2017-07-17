import Lynx
import Dispatch

public protocol SyncRouter : Router {}

/// Vapor API
extension SyncRouter {
    /// Registers a route
    fileprivate func register(_ path: [String], method: Lynx.Method, handler: @escaping ((Request) throws -> (ResponseRepresentable))) {
        self.register(at: path, method: method) { request, client in
            do {
                let response = try handler(request)
                
                try response.makeResponse().send(to: client)
            } catch let error as Encodable {
                Application.logger?.log(error, level: .error)
                client.close()
            } catch {
                client.close()
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

