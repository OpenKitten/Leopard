import Lynx

/// A WebSocket router is used to route websocket connections
public protocol WebsocketRouter : Router {}

extension WebsocketRouter {
    /// Registers a websocket accepting route at the given path. Supports path components.
    ///
    /// Handles an incoming WebSocket. If you don't store the websocket anywhere it will be deallocated,
    /// closing the connection
    public func websocket(_ path: String..., handler: @escaping ((WebSocket) throws -> ())) {
        self.register(at: path, method: .get, isFallbackHandler: false) { req, remote in
            guard let client = remote as? Client else {
                remote.error(WebSocketError.couldNotConnect)
                return
            }
            
            do {
                let websocket = try WebSocket(from: req, to: client)
                
                try handler(websocket)
            } catch let error as Encodable & Error {
                Application.logger?.log(error, level: .error)
                remote.error(error)
            } catch {
                remote.error(error)
            }
        }
    }
}
