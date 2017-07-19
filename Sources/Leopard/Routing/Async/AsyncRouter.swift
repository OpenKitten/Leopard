@_exported import Lynx
@_exported import Schrodinger

public protocol AsyncRouter : Router {}

extension AsyncRouter {
    public typealias AsyncHandler = ((Request) throws -> (Future<ResponseRepresentable>))
    
    public func register(method: Method, at path: [String], handler: @escaping AsyncHandler) {
        self.register(at: path, method: method)  { request, remote in
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
