import Lynx

public protocol SyncMiddleware {
    func handle(_ request: Request, for remote: HTTPRemote, chainingTo handler: RequestHandler)
}
