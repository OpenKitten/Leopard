import XCTest
import Cheetah
@testable import Leopard

class ValidationTests: XCTestCase {
    func testBasicFormValidation() throws {
        XCTAssertNoThrow(try RegisterForm(username: "henk", password: "hunter2", age: 21, male: true).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "joannis", password: "hunter2", age: 21, male: true).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "henk", password: "a", age: 21, male: true).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "henk", password: "hunter2", age: 1314, male: true).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "henk", password: "hunter2", age: 21, male: false).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "joannis", password: "a", age: 21, male: true).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "henk", password: "a", age: 1314, male: true).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "henk", password: "hunter2", age: 1314, male: false).assertValid())
    }
}

struct RegisterForm : FormRequest {
    var username: String
    var password: String
    var age: Int
    var male: Bool
    
    func validate(loggingTo validationLogger: ValidationLogger) throws {
        validationLogger.assert(self.username == "henk")
        validationLogger.assert(self.age < 100)
        validationLogger.assert(self.age > 18)
        validationLogger.assert(self.password.characters.count > 3)
        validationLogger.assert(self.male == true)
    }
}
