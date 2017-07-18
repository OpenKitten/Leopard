import XCTest
import MongoKitten
import ExtendedJSON
@testable import Leopard

extension SyncWebServer : 

class RoutingTests: XCTestCase {
    func testSyncRouteGrouping() throws {
        let server = try SyncWebServer()
        
        server.group(["path", "to"]) { group in
            group.group(["group", "to"]) { group in
                group.get("route") { _ in
                    return "result"
                }
            }
        }
        
        try server.handle(Request(method: .get, url: "/path/to/group/to/route", headers: [:]), for: TestClient { response in
            guard
        })
    }
    
    func testAsyncRouting() throws {
        let db = try Database("mongodb://localhost/leopard")
        
        let server = try SyncWebServer()
//        router.get("/user/:user/friends") { request in
//            guard
//                let username = try request.extract(String.self, from: ":user") else {
//                    throw InvalidRequest()
//            }
//            
//            return try db["users"].findOne("username" == username) { user in
//                guard let user = user else {
//                    throw NotFound()
//                }
//                
//                return try user.friends.resolve { friends in
//                    return try friends.makeJSON()
//                }
//            }
//        }
        
        try db["users"].remove()
        
        let id = try db["users"].insert([
            "username": "root"
        ])
        
        try db["users"].insert([
            "username": "test0",
            "friend": id
        ])
        
        try db["users"].insert([
            "username": "test1",
            "friend": id
        ])
        
        try db["users"].insert([
            "username": "test2",
            "friend": id
        ])
        
        var sockets = [WebSocket]()
        
        server.websocket("pong") { websocket in
            websocket.onText { text in
                try websocket.send(text)
            }
            
            sockets.append(websocket)
        }
        
        server.get("user", ":user", "friends") { request in
            let username = try request.extract(from: "user")
            
            guard let user = try db["users"].findOne("username" == username) else {
                throw NotFound()
            }
            
            let friends = try db["users"].find("friend" == user["_id"])
            
            return Document(array: Array(friends)).makeExtendedJSONString()
        }
        
        try server.start()
    }


    static var allTests: [(String, (RoutingTests) -> () throws -> Void)] = [
        ("testAsyncRouting", testAsyncRouting),
    ]
}

struct NotFound : Error {}
