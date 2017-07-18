#if Xcode
    private var workDir: String {
        let parent = #file.characters.split(separator: "/").map(String.init).dropLast().joined(separator: "/")
        let path = "/\(parent)/../../Tests/Resources/"
        return path
    }
#else
    private let workDir = "./Tests/Resources/"
#endif

import XCTest
import MongoKitten
import ExtendedJSON
@testable import Leopard

class ConfigTests: XCTestCase {
    func testBasicConfig() throws {
        guard let config = try Config.decodeFromJSON(atPath: workDir + "Basic.json") else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(config.routingToken, ":")
        XCTAssertEqual(config.port, 1337)
        XCTAssertEqual(config.hostname, "openkitten.org")
        
        let server = try AsyncWebServer(config)
        
        XCTAssertEqual(server.router.tokenByte, 0x3a)
    }
}

class Config : RoutingConfig, HTTPServerConfig {
    var routingToken: String? = ":"
    var port: UInt16 = 80
    var hostname: String = "0.0.0.0"
}