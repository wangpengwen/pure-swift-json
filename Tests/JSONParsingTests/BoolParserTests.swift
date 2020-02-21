import XCTest
@testable import PureSwiftJSONParsing

class BoolParserTests: XCTestCase {
  
  func testSimpleTrue() throws {
    var parser = JSONParserImpl(bytes: [UInt8]("true".utf8))
    _ = try XCTUnwrap(parser.reader.read())
    
    let result = try parser.parseBool()
    XCTAssertEqual(result, true)
  }
  
  func testSimpleFalse() throws {
    var parser = JSONParserImpl(bytes: [UInt8]("false".utf8))
    _ = try XCTUnwrap(parser.reader.read())
    
    let result = try parser.parseBool()
    XCTAssertEqual(result, false)
  }
  
  func testFalseOtherCharactersFollowing() throws {
    var parser = JSONParserImpl(bytes: [UInt8]("false,".utf8))
    _ = try XCTUnwrap(parser.reader.read())
    
    let result = try parser.parseBool()
    XCTAssertEqual(result, false)
    
    var remaining: [UInt8] = []
    while let (byte, _) = parser.reader.read() {
      remaining.append(byte)
    }
    
    XCTAssertEqual(remaining, [UInt8(ascii: ",")])
  }
  
  func testInvalidCharacter() throws {
    var parser = JSONParserImpl(bytes: [UInt8]("fal67,".utf8))
    _ = try XCTUnwrap(parser.reader.read())

    
    do {
      _ = try parser.parseBool()
      XCTFail("this point should not be reached")
    }
    catch JSONError.unexpectedCharacter(ascii: UInt8(ascii: "6")) {
      // expected
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
}