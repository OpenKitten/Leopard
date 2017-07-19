import Lynx
import Dispatch

public protocol Middleware {
    func handle(_ request: Request, for remote: HTTPRemote, chainingTo handler: RequestHandler)
}

public protocol BasicMiddleware : Middleware {
    func handle(_ request: Request, chainingTo handler: (() -> (Future<ResponseRepresentable>))) throws -> Future<ResponseRepresentable>
}

public struct FutureRemote : HTTPRemote {
    let promise = Future<ResponseRepresentable>()
    
    public func error(_ error: Error) {
        do {
            try promise.complete {
                throw error
            }
        } catch let error as Encodable {
            Application.logger?.log(error, level: .error)
        } catch {}
    }
    
    public func send(_ response: Response) throws {
        try promise.complete { response }
    }
    
    public init() {}
}

extension BasicMiddleware {
    public func handle(_ request: Request, for remote: HTTPRemote, chainingTo handler: @escaping (Request, HTTPRemote) -> ()) {
        do {
            try self.handle(request) {
                let futureRemote = FutureRemote()
                
                handler(request, futureRemote)
                
                return futureRemote.promise
            }.then { response in
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
