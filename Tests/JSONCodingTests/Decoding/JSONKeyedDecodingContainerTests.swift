import XCTest
@testable import PureSwiftJSONParsing
@testable import PureSwiftJSONCoding

class JSONKeyedDecodingContainerTests: XCTestCase {
  
  func testAllKeys() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .null, "world": .null]), codingPath: [])
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let keys = container.allKeys
      XCTAssertEqual(keys.count, 1)
      XCTAssertEqual(keys.first, .hello)
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testContains() throws {
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .null, "world": .null]), codingPath: [])
    
    enum CodingKeys: String, CodingKey {
      case hello
      case haha
    }
    
    let container = try impl.container(keyedBy: CodingKeys.self)
    XCTAssertEqual(container.contains(.hello), true)
    XCTAssertEqual(container.contains(.haha), false)
  }
  
  // MARK: - Null -
  
  func testDecodeNullFromNothing() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .object([:]), codingPath: [])
    enum CodingKeys: String, CodingKey {
      case hello
    }
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decodeNil(forKey: .hello)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.keyNotFound(let codingKey, let context) {
      // expected
      XCTAssertEqual(codingKey as? CodingKeys, .hello)
      XCTAssertEqual(context.debugDescription, "No value associated with key CodingKeys(stringValue: \"hello\", intValue: nil) (\"hello\").")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testDecodeNull() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .null]), codingPath: [])
    enum CodingKeys: String, CodingKey {
      case hello
    }
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decodeNil(forKey: .hello)
      XCTAssertEqual(result, true)
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testDecodeNullFromArray() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .array([])]), codingPath: [])
    enum CodingKeys: String, CodingKey {
      case hello
    }
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decodeNil(forKey: .hello)
      XCTAssertEqual(result, false)
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  // MARK: - String -
  
  func testDecodeStringFromNumber() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("12")]), codingPath: [])
    enum CodingKeys: String, CodingKey {
      case hello
    }
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(String.self, forKey: .hello)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.typeMismatch(let type, let context) {
      // expected
      XCTAssertTrue(type == String.self)
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first as? CodingKeys, CodingKeys.hello)
      XCTAssertEqual(context.debugDescription, "Expected to decode String but found a number instead.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testDecodeStringFromKeyNotFound() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .object([:]), codingPath: [])
    enum CodingKeys: String, CodingKey {
      case hello
    }
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(String.self, forKey: .hello)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.keyNotFound(let codingKey, let context) {
      // expected
      XCTAssertEqual(codingKey as? CodingKeys, .hello)
      XCTAssertEqual(context.debugDescription, "No value associated with key CodingKeys(stringValue: \"hello\", intValue: nil) (\"hello\").")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  // MARK: - Bool -
  
  func testDecodeBoolFromNumber() {
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("12")]), codingPath: [])
    enum CodingKeys: String, CodingKey {
      case hello
    }
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(Bool.self, forKey: .hello)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.typeMismatch(let type, let context) {
      // expected
      XCTAssertTrue(type == Bool.self)
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first as? CodingKeys, CodingKeys.hello)
      XCTAssertEqual(context.debugDescription, "Expected to decode Bool but found a number instead.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  // MARK: - Integers -
  
  func testGetUInt8FromTooLargeNumber() {
    let number = 312
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    enum CodingKeys: String, CodingKey {
      case hello
    }
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(UInt8.self, forKey: .hello)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.dataCorrupted(let context) {
      // expected
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first as? CodingKeys, .hello)
      XCTAssertEqual(context.debugDescription, "Parsed JSON number <\(number)> does not fit in UInt8.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetUInt8FromFloat() {
    let number = -3.14
    let type = UInt8.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.dataCorrupted(let context) {
      // expected
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first as? CodingKeys, .hello)
      XCTAssertEqual(context.debugDescription, "Parsed JSON number <\(number)> does not fit in UInt8.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetUInt8TypeMismatch() {
    let type = UInt8.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .bool(false)]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.typeMismatch(let type, let context) {
      // expected
      XCTAssertTrue(type == UInt8.self)
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first as? CodingKeys, .hello)
      XCTAssertEqual(context.debugDescription, "Expected to decode UInt8 but found bool instead.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testGetUInt8Success() {
    let number = 25
    let type = UInt8.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetUInt16Success() {
    let number = 25
    let type = UInt16.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetUInt32Success() {
    let number = 25
    let type = UInt32.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetUInt64Success() {
    let number = 25
    let type = UInt64.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testGetUIntSuccess() {
    let number = 25
    let type = UInt.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testGetInt8Success() {
    let number = -25
    let type = Int8.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetInt16Success() {
    let number = -25
    let type = Int16.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetInt32Success() {
    let number = -25
    let type = Int32.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetInt64Success() {
    let number = -25
    let type = Int64.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testGetIntSuccess() {
    let number = -25
    let type = Int.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  // MARK: - Floats -
  
  func testGetFloatSuccess() {
    let number = -3.14
    let type = Float.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetDoubleSuccess() {
    let number = -3.14e12
    let type = Double.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetFloatTooPreciseButNoProblemo() {
    let number = 3.14159265358979323846264338327950288419716939937510582097494459230781640
    let type = Float.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .number("\(number)")]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTAssertEqual(result, type.init(number)) // works only because we compare based on float
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testGetFloat1000e1000() {
    let type = Float.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
    
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello" : .number("1000e1000")]), codingPath: [])
      
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.dataCorrupted(let context) {
      // expected
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first?.stringValue, "hello")
      XCTAssertEqual(context.debugDescription, "Parsed JSON number <1000e1000> does not fit in Float.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  
  func testGetFloatTypeMismatch() {
    let type = Float.self
    
    enum CodingKeys: String, CodingKey {
      case hello
    }
      
    let impl = JSONDecoderImpl(userInfo: [:], from: .object(["hello": .bool(false)]), codingPath: [])
    
    do {
      let container = try impl.container(keyedBy: CodingKeys.self)
      let result = try container.decode(type.self, forKey: .hello)
      XCTFail("Did not expect to get a result: \(result)")
    }
    catch Swift.DecodingError.typeMismatch(let type, let context) {
      // expected
      XCTAssertTrue(type == Float.self)
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first as? CodingKeys, .hello)
      XCTAssertEqual(context.debugDescription, "Expected to decode Float but found bool instead.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
}
