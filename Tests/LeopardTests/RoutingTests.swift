import Lynx
import XCTest
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
    func testNotFound() throws {
        let router = TrieRouter()
        router.fallbackHandler = Lynx.NotFound(body: "Not Found").handle
        
        router.handle(Request(method: .get, path: "/"), for: TestClient { response in
            XCTAssert(response.status == Status.notFound)
        })
        
        router.register(at: [], method: .get, handler: { _, client in
            do {
                try client.send(try "test".makeResponse())
            } catch {
                client.error(error)
            }
        })
        
        router.handle(Request(method: .get, path: "/"), for: TestClient { response in
            XCTAssert(response.status == Status.ok)
            XCTAssertEqual(response.body?.string, "test")
        })
    }
    
    func testSyncMiddlewares() throws {
        let server = try SyncWebServer(middlewares: [InterceptorMiddleware()])
        
        let request = Request(method: .get, path: "/")
        
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
    
    func testAsyncMiddlewares() throws {
        let server = try AsyncWebServer(middlewares: [InterceptorMiddleware()])
        
        let request = Request(method: .get, path: "/")
        
        server.get { request in
            return Future { "don't get here" }
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
        
        let request = Request(method: .get, path: "/path/to/group/to/route", headers: [
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


    static var allTests: [(String, (RoutingTests) -> () throws -> Void)] = [
//        ("testAsyncRouting", testAsyncRouting),
    ]
}

struct NotFound : Error {}
