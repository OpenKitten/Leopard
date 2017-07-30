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
