import XCTest
import Cheetah
@testable import Leopard

class ValidationTests: XCTestCase {
    func testBasicFormValidation() throws {
        XCTAssertNoThrow(try RegisterForm(username: "henk", password: "hunter2", age: 21, programmer: true, optional: nil).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "henk", password: "hunter2", age: 21, programmer: true, optional: "nil").assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "joannis", password: "hunter2", age: 21, programmer: true, optional: nil).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "henk", password: "a", age: 21, programmer: true, optional: nil).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "henk", password: "hunter2", age: 1314, programmer: true, optional: nil).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "henk", password: "hunter2", age: 21, programmer: false, optional: nil).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "joannis", password: "a", age: 21, programmer: true, optional: nil).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "henk", password: "a", age: 1314, programmer: true, optional: nil).assertValid())
        XCTAssertThrowsError(try RegisterForm(username: "henk", password: "hunter2", age: 1314, programmer: false, optional: nil).assertValid())
    }
}

struct RegisterForm : Validatable {
    var username: String
    var password: String
    var age: Int
    var programmer: Bool
    var optional: String?
    
    func validate(loggingTo validator: Validator) throws {
        validator.assert(self.username == "henk").or("Invalid username")
        validator.assert(self.age < 100).or("Too old")
        validator.assert(self.age > 18).or("Too young")
        validator.assert(self.password.characters.count > 3).or("Passsword too short")
        validator.assert(self.programmer == true).or("Not a programmer")
        validator.assertTrue(self.programmer).or("Not a programmer")
        validator.assertFalse(!self.programmer).or("Not a programmer")
        validator.assertNil(optional).or("Not nil")
    }
}
