import XCTest
import MongoKitten
import ExtendedJSON
@testable import Leopard

extension TestClient {
    init(_ closure: @escaping ResponseHandler) {
        self.init(closure, or: { _ in XCTFail() })
    }
}

extension Body {
    var string: String? {
        return String(bytes: self.buffer, encoding: .utf8)
    }
}

struct InterceptorMiddleware : Middleware {
    func handle(_ request: Request, for remote: HTTPRemote, chainingTo handler: (Request, HTTPRemote) -> ()) {
        do {
            try remote.send(try "intercepted".makeResponse())
        } catch {
            remote.error(error)
        }
    }
}

class RoutingTests: XCTestCase {
    func testAsyncMiddlewares() throws {
        let server = try SyncWebServer(middlewares: [InterceptorMiddleware()])
        
        let request = Request(method: .get, url: "/")
        
        server.get { request in
            return "don't get here"
        }
        
        var received = false
        
        server.handle(request, for: TestClient { response in
            guard let result = response.body as? String else {
                XCTFail()
                return
            }
            
            received = true
            XCTAssertEqual(result, "intercepted")
        })
        
        XCTAssert(received)
    }
    
    func testSyncRouteGrouping() throws {
        let server = try SyncWebServer()
        
        server.group(["path", "to"]) { group in
            group.group(["group", "to"]) { group in
                group.get("route") { request in
                    XCTAssertEqual(request.headers.host, "localhost:8080")
                    XCTAssertEqual(request.headers.bearer, "sdasdsfascasdsads")
                    
                    return "result"
                }
            }
        }
        
        let request = Request(method: .get, url: "/path/to/group/to/route", headers: [
            "Host": "localhost:8080",
            "Authorization": "Bearer sdasdsfascasdsads"
        ])
        
        server.handle(request, for: TestClient { response in
            guard let result = try response.body?.makeBody().string else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(result, "result")
        })
    }
    
//    func testAsyncRouting() throws {
//        let db = try Database("mongodb://localhost/leopard")
//
//        let server = try SyncWebServer()
////        router.get("/user/:user/friends") { request in
////            guard
////                let username = try request.extract(String.self, from: ":user") else {
////                    throw InvalidRequest()
////            }
////
////            return try db["users"].findOne("username" == username) { user in
////                guard let user = user else {
////                    throw NotFound()
////                }
////
////                return try user.friends.resolve { friends in
////                    return try friends.makeJSON()
////                }
////            }
////        }
//
//        try db["users"].remove()
//
//        let id = try db["users"].insert([
//            "username": "root"
//        ])
//
//        try db["users"].insert([
//            "username": "test0",
//            "friend": id
//        ])
//
//        try db["users"].insert([
//            "username": "test1",
//            "friend": id
//        ])
//
//        try db["users"].insert([
//            "username": "test2",
//            "friend": id
//        ])
//
//        var sockets = [WebSocket]()
//
//        server.websocket("pong") { websocket in
//            websocket.onText { text in
//                try websocket.send(text)
//            }
//
//            sockets.append(websocket)
//        }
//
//        server.get("user", ":user", "friends") { request in
//            let username = try request.extract(from: "user")
//
//            guard let user = try db["users"].findOne("username" == username) else {
//                throw NotFound()
//            }
//
//            let friends = try db["users"].find("friend" == user["_id"])
//
//            return Document(array: Array(friends)).makeExtendedJSONString()
//        }
//
//        try server.start()
//    }


    static var allTests: [(String, (RoutingTests) -> () throws -> Void)] = [
//        ("testAsyncRouting", testAsyncRouting),
    ]
}

struct NotFound : Error {}
