import XCTest
@testable import Leopard

class HeadersTests: XCTestCase {
    func testBasics() throws {
        var headers = Headers()
        
        headers["kaas"] = "meep"
        XCTAssertEqual(headers["kaas"], "meep")
        
        headers["henk"] = "meep"
        XCTAssertEqual(headers["henk"], "meep")
        
        headers["kaas"] = nil
        XCTAssertEqual(headers["kaas"], nil)
        XCTAssertEqual(headers["henk"], "meep")
    }
    
    func testCookies() throws {
        var cookies = Cookies()
        cookies["kaas"] = "kaas"
        cookies["sap"] = "sap"
        cookies["saus"] = "saus"
        
        let request = Request(method: .get, path: "/")
        request.cookies = cookies
        
        XCTAssertEqual(request.cookies["kaas"]?.value, "kaas")
        XCTAssertEqual(request.cookies["sap"]?.value, "sap")
        XCTAssertEqual(request.cookies["saus"]?.value, "saus")
    }
}
