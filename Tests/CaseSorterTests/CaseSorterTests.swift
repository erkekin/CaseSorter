import XCTest
@testable import CaseSorter
import SwiftSyntax
import Basic

final class CaseSorterTests: XCTestCase {
  private var caseSorter: CaseSorter!

  override func setUp() {
    super.setUp()
    caseSorter = CaseSorter()

  }

  override func tearDown() {
    caseSorter = nil
    super.tearDown()
  }


  func testClosureSyntax_defaultCase() {
    let input = """
                private func canOpen(serviceType: String) -> Bool {
                  switch serviceType {
                  case SLServiceTypeFacebook:
                    return canOpenURL(URL(string: "fb://")!)
                  case SLServiceTypeTwitter:
                    return canOpenURL(URL(string: "twitter://")!)
                  default:
                    return false
                  }
                }
                """

    let expected = """
                   private func canOpen(serviceType: String) -> Bool {
                     switch serviceType {
                     case SLServiceTypeFacebook:
                       return canOpenURL(URL(string: "fb://")!)
                     case SLServiceTypeTwitter:
                       return canOpenURL(URL(string: "twitter://")!)
                     default:
                       return false
                     }
                   }
                   """

    let actual = visitor(input: input)
    XCTAssertEqual(actual.description, expected)
  }


  func testClosureSyntax_nested_enum_switchCases() {
    let input = """
                enum Theme {
                  case a(String)
                  case b(Int)

                  func e(ss: Theme) {
                    switch ss {
                    case let .a(_),.s:
                      ()
                    case let .b(_):
                      ()
                    }
                  }
                  case s
                }

                """

    let expected = """
                   enum Theme {
                     case a(String)
                     case b(Int)

                     func e(ss: Theme) {
                       switch ss {
                       case let .a(_), .s:
                         ()
                       case let .b(_):
                         ()
                       }
                     }
                     case s
                   }

                   """

    let actual = visitor(input: input)
    XCTAssertEqual(actual.description, expected)
  }



  func testClosureSyntax_switchCaseLet() {
    let input = """
                switch erk {
                  case .sa, let .da(_):
                    ()
                  case .s, .a:
                    ()
                }
                """

    let expected = """
                   switch erk {
                     case .a, .s:
                       ()
                     case let .da(_), .sa:
                       ()
                   }
                   """

    let actual = visitor(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_complexSwitch() {

    let input = """
                 extension JSON {
                   func serialize() -> Any {
                     switch self {
                     case let .dict(dict):
                       var serializedDict = [String: Any]()
                       for (key, value) in dict {
                         serializedDict[key] = value.serialize()
                       }
                       return serializedDict
                     case .s, let .array(array):
                       return array.map { $0.serialize() }
                     case let .string(string):
                       return string
                     case let .number(number):
                       return number
                     case let .bool(bool):
                       return NSNumber(value: bool)
                     case .null:
                       return NSNull()
                     }
                   }
                 }
                """

    let expected = """
                    extension JSON {
                      func serialize() -> Any {
                        switch self {
                        case let .array(array), .s:
                          return array.map { $0.serialize() }
                        case let .bool(bool):
                          return NSNumber(value: bool)
                        case let .dict(dict):
                          var serializedDict = [String: Any]()
                          for (key, value) in dict {
                            serializedDict[key] = value.serialize()
                          }
                          return serializedDict
                        case .null:
                          return NSNull()
                        case let .number(number):
                          return number
                        case let .string(string):
                          return string
                        }
                      }
                    }
                   """

    let actual = visitor(input: input)
    XCTAssertEqual(actual.description, expected)
  }


  func testClosureSyntax_multipleCasesSameRow() {
    let input = """
                 enum Theme {
                   case z,g,c
                   case d,y
                   case a
                   case b
                 }
                """

    let expected = """
                    enum Theme {
                      case a
                      case b
                      case c, g, z
                      case d, y
                    }
                   """

    let actual = visitor(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_caseSensitiveness() {
    let input = """
                 enum Theme {
                   case Bbc,BBC,BBc
                   case abc
                   case bbc
                   case Abc
                 }
                """

    let expected = """
                    enum Theme {
                      case abc
                      case Abc
                      case BBc, Bbc, BBC
                      case bbc
                    }
                   """

    let actual = visitor(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_enum_oneLineCases() {
    let input = """
                enum Theme {
                  case k(String), u, a
                  case b
                }
               """

    let expected = """
                   enum Theme {
                     case a, k(String), u
                     case b
                   }
                  """

    let actual = visitor(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_switch_inside_enum() {
    let input = """
                enum Theme {
                  case a
                  case b
                  init?(_ str: String) {
                    switch str {
                    case "a":
                      self = .a
                    case "b":
                      self = .b
                    default:
                      return nil
                    }
                  }
                }
               """

    let expected = """
                   enum Theme {
                     case a
                     case b
                     init?(_ str: String) {
                       switch str {
                       case "a":
                         self = .a
                       case "b":
                         self = .b
                       default:
                         return nil
                       }
                     }
                   }
                  """

    let actual = visitor(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_switch_insideStruct() {
    let input =  """
                struct Test{
                  init(_ theme: Theme) {
                    switch theme {
                    case .light:
                      print("light")
                    case .dark:
                      print("dark")
                    }
                  }
                }
              """

    let expected =  """
                   struct Test{
                     init(_ theme: Theme) {
                       switch theme {
                       case .dark:
                         print("dark")
                       case .light:
                         print("light")
                       }
                     }
                   }
                 """

    let actual = visitor(input: input)
    XCTAssertEqual(actual.description, expected)
  }



  func testClosureSyntax_enum() {
    let input =  """
        enum Dnm{
          static let  a =
          399
          static let  fdfdf =
          399
          case v
          func erk(){


          }
          case b(firstOne:String,
            secondOne: Int)

          case we
          case aasd
        }
        """

    let expected =
    """
        enum Dnm{
          case aasd
          case b(firstOne:String,
            secondOne: Int)
          func erk(){


          }
          static let  a =
          399
          static let  fdfdf =
          399
          case v

          case we
        }
        """

    let actual = visitor(input: input)
    XCTAssertEqual(actual.description, expected)

  }

  func testClosureSyntax_switch() {

    let input =
    """
      switch a{
      case .zsdfsdf:
        ()
      case .ydfgdfg:
        ()
      case .rfghfgh:
        ()
      case .hhgg:
        ()
      }
      """

    let expected =
    """
      switch a{
      case .hhgg:
        ()
      case .rfghfgh:
        ()
      case .ydfgdfg:
        ()
      case .zsdfsdf:
        ()
      }
      """

    let actual = visitor(input: input)

    XCTAssertEqual(actual.description, expected)
  }

  func visitor(input: String) -> Syntax {
    let tempfile = try! TemporaryFile(deleteOnClose: true)
    defer { tempfile.fileHandle.closeFile() }
    tempfile.fileHandle.write(input.data(using: .utf8)!)
    let url = URL(fileURLWithPath: tempfile.path.pathString)
    let sourceFile = try! SyntaxTreeParser.parse(url)
    return caseSorter.visit(sourceFile)
  }

  static var allTests = [
    ("testClosureSyntax_enum", testClosureSyntax_enum),
  ]
}




//switch (lhs, rhs) {
//case (.howItWorks, .howItWorks),
//           (.summary, .summary):
//         (.processingPlan, .processingPlan),
//     (.normalPlan, .normalPlan),
//
//
//  return true
//case (.normalPlan, _),
//          (.summary, _):
//     (.howItWorks, _),
//     (.processingPlan, _),
//
//  return false
//}


//enum Theme {
//  case a(String)
//  case b(Int)
//
//  func e(ss: Theme) {
//    switch ss {
//    case let .a(_),.s:
//      ()
//    default:
//      ()
//    }
//  }
//  case s
//}
//
//
//enum MessageType: Int {
//  case success = 0, failure
//}


