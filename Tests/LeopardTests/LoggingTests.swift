import XCTest
import Cheetah
@testable import Leopard

class LoggingTests: XCTestCase {
    func testBasicLogs() throws {
        let request = Request(method: .get, path: "/path/to/group/to/route", headers: [
            "Host": "localhost:8081",
            "Authorization": "Bearer sdasdsfascasdsads"
        ])
        
        let logger = JSONLogger { string in
            XCTAssert(string.starts(with: "verbose: "))
            var string = string
            string.removeFirst("verbose: ".characters.count)
            
            do {
                let request = try JSONDecoder().decode(Request.self, from: string)
                
                XCTAssertEqual(request.headers.host, "localhost:8081")
                XCTAssertEqual(request.headers.bearer, "sdasdsfascasdsads")
                XCTAssertEqual(request.method, .get)
                XCTAssertEqual(request.path, "/path/to/group/to/route")
            } catch {
                XCTFail()
            }
        }
        
        logger.log(request, level: .verbose)
        
        let logger2 = JSONLogger { string in
            XCTAssertEqual("verbose: test", string)
        }
        
        logger2.log("test", level: .verbose)
    }
}
