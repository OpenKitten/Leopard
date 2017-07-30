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
@testable import Leopard

class ConfigTests: XCTestCase {
    func testWS() throws {
        let config = Config()
        config.port = 8080
        
        let ws = try WebServer(config)
        
        ws.websocket("ws") { ws in
            ws.onText = { ws, string in
                try ws.send(string)
            }
            
            ws.onBinary = { ws, buffer in
                try ws.send(buffer)
            }
//            ws.close()
        }
        
        try ws.start()
    }
    
    func testBasicConfig() throws {
        guard let config = try Config.decodeFromJSON(atPath: workDir + "Basic.json") else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(config.routeParameterToken, ":")
        XCTAssertEqual(config.port, 1337)
        XCTAssertEqual(config.hostname, "openkitten.org")
        
        let server = try WebServer(config)
        
        XCTAssertEqual(server.router.tokenByte, 0x3a)
    }
}

class Config : RoutingConfig, HTTPServerConfig {
    var splitPaths: Bool?
    var routeParameterToken: String? = ":"
    var port: UInt16 = 80
    var hostname: String = "0.0.0.0"
}
