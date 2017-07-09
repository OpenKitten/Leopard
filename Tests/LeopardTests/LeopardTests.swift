import XCTest
import MongoKitten
@testable import Leopard

class LeopardTests: XCTestCase {
    func testAsyncRouting() throws {
        let db = try Database("mongodb://localhost/leopard")
        
        let server = try AsyncWebServer()
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
        
        server.get("/user/:user/friends") { request in
            guard let username = try request.extract(String.self, from: ":user") else {
                throw InvalidRequest()
            }
            
            return try db["users"].findOneAsync("username" == username).replace { user in
                guard let user = user else {
                    throw NotFound()
                }
                
                return try db["users"].findAsync("friend" == user["_id"]).map { friends in
                    return Array(friends).makeExtendedJSON().serializedString()
                }
            }
        }
        
        try server.start()
    }


    static var allTests: [(String, (LeopardTests) -> () throws -> Void)] = [
        ("testAsyncRouting", testAsyncRouting),
    ]
}

struct NotFound : Error {}
struct InvalidRequest : Error {}
