@testable import Leopard
import XCTest
import Cheetah

class HelperTests : XCTestCase {
    func testBody() throws {
        let data: [UInt8] = [0x00, 0x01, 0x00, 0x04]
        
        let body = Body(data)
        
        let newData = Array(try body.makeBody().buffer)
        
        XCTAssert(data == newData)
    }
    
    func testJSONObject() throws {
        let object: JSONObject = [
            "test": true
        ]
        
        let body = try object.makeBody()
        
        XCTAssertEqual(Array(body.buffer), object.serialize())
        
        XCTAssertEqual(body.jsonObject, body.jsonObject ?? [:])
    }
    
    func testJSONArray() throws {
        let array: JSONArray = [0, 1, 2, 3]
        
        let body = try array.makeBody()
        
        XCTAssertEqual(Array(body.buffer), array.serialize())
    }
}
