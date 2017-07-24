import Lynx
import Dispatch

/// A middleware, handled requests before each successive middleware and, finally, the route handler
public protocol Middleware {
    /// Handles the request and may not throw an error.
    ///
    /// Must respond to the provided femote
    ///
    /// Can pass the request to the next RequestHandler unless intercepted
    func handle(_ request: Request, for remote: HTTPRemote, chainingTo handler: RequestHandler)
}

/// A basic (simplified) middleware, with a simpler API
public protocol BasicMiddleware : Middleware {
    /// Handles the request, may throw an error.
    ///
    /// Returns a future containing a possible response.
    func handle(_ request: Request, chainingTo handle: (() -> (Future<ResponseRepresentable>))) throws -> Future<ResponseRepresentable>
}

/// A Future helper that helper helps handling requests in the future
public struct FutureRemote : HTTPRemote {
    let promise = Future<ResponseRepresentable>()
    
    /// Called when an error occurs
    public func error(_ error: Error) {
        do {
            try promise.complete {
                throw error
            }
        } catch let error as Encodable {
            Application.logger?.log(error, level: .error)
        } catch {}
    }
    
    /// Called when the response is ready
    public func send(_ response: Response) throws {
        try promise.complete { response }
    }
    
    public init() {}
}

extension BasicMiddleware {
    /// Takes care of complex async code for BasicMiddlewares
    public func handle(_ request: Request, for remote: HTTPRemote, chainingTo handler: @escaping (Request, HTTPRemote) -> ()) {
        do {
            // Try to handle the request
            try self.handle(request) {
                // Chains to the next remote
                let futureRemote = FutureRemote()
                
                handler(request, futureRemote)
                
                return futureRemote.promise
            // When the chain is finished calling
            }.then { response in
                do {
                    // Send the response back to the client
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
