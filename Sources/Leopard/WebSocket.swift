import Lynx

public protocol WebsocketRouter : Router {
    
}

extension WebsocketRouter {
    public func websocket(_ path: String..., handler: @escaping ((WebSocket) throws -> ())) {
        self.register(at: path, method: .get) { req, client in
            do {
                let websocket = try WebSocket(from: req, to: client)
                
                try handler(websocket)
            
            } catch {
//                log(error: error)
                client.close()
            }
        }
    }
}
