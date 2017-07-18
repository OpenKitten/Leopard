import Lynx

public protocol WebsocketRouter : Router {
    
}

extension WebsocketRouter {
    public func websocket(_ path: String..., handler: @escaping ((WebSocket) throws -> ())) {
        self.register(at: path, method: .get) { req, remote in
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
