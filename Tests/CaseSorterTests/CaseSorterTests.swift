import XCTest
@testable import CaseSorter
import SwiftSyntax

@available(OSX 10.12, *)
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

  func testSwitchSyntax_withTuple2() throws {
    let input = """
                 enum erk{

                   case c
                   case hg

                   func erjrr(_ s: erk){
                     switch (s, s) {
                     case (.c, _):
                       break
                     case (.b(_), _):
                       break

                     case (.hg, _):
                       break
                     case (_, .c):
                       break
                     case (_, .a(_)):
                       break

                     case (_, .hg):
                       break
                     case (.a(_), .b(_)):
                       break
                     }
                   }

                   case b(Int)
                   case a(String)
                 }
                 """

    let expected = """
                 enum erk{
                   case a(String)

                   case b(Int)

                   case c
                   case hg

                   func erjrr(_ s: erk){
                     switch (s, s) {
                     case (_, .c):
                       break
                     case (_, .a(_)):
                       break

                     case (_, .hg):
                       break
                     case (.c, _):
                       break
                     case (.a(_), .b(_)):
                       break
                     case (.b(_), _):
                       break

                     case (.hg, _):
                       break
                     }
                   }
                 }
                 """

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testEnumSyntax_withComputedVariables() throws {
    let input = """
                  public enum InitialState {
                    case loggingIn
                    case switchingCards
                    case selectingCard
                    case refreshingAccountSummary

                    var state: State {
                      switch self {
                      case .loggingIn, .switchingCards, .selectingCard:
                        return .expanded(nil)
                      case .refreshingAccountSummary:
                        return .stacked(nil)
                      }
                    }

                    var mode: Mode {
                      switch self {
                      case .loggingIn, .switchingCards, .selectingCard:
                        return .expanded
                      case .refreshingAccountSummary:
                        return .stacked
                      }
                    }

                    var collapseMode: CollapseMode {
                      switch self {
                      case .switchingCards, .refreshingAccountSummary:
                        return .auto(delay: nil)
                      case .selectingCard:
                        return .manual
                      case .loggingIn:
                        return .auto(delay: 1.0)
                      }
                    }
                  }
                 """

    let expected = """
     public enum InitialState {
       case loggingIn
       case refreshingAccountSummary
       case selectingCard
       case switchingCards

       var state: State {
         switch self {
         case .loggingIn, .selectingCard, .switchingCards:
           return .expanded(nil)
         case .refreshingAccountSummary:
           return .stacked(nil)
         }
       }

       var mode: Mode {
         switch self {
         case .loggingIn, .selectingCard, .switchingCards:
           return .expanded
         case .refreshingAccountSummary:
           return .stacked
         }
       }

       var collapseMode: CollapseMode {
         switch self {
         case .loggingIn:
           return .auto(delay: 1.0)
         case .selectingCard:
           return .manual
         case .refreshingAccountSummary, .switchingCards:
           return .auto(delay: nil)
         }
       }
     }
    """

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testSwitchSyntax_withTuple() throws {
    let input = """
                 switch (one, two) {
                     case (_ , .dz, .a):
                         break
                     case (.nm, .mj, .sfdf):
                         break
                     case let .afhjgj(a):
                         break
                 }
                 """

    let expected = """
                 switch (one, two) {
                     case (_ , .dz, .a):
                         break
                     case let .afhjgj(a):
                         break
                     case (.nm, .mj, .sfdf):
                         break
                 }
                 """

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_defaultCase() throws {
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

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }


  func testClosureSyntax_nested_enum_switchCases() throws {
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
                     case s

                     func e(ss: Theme) {
                       switch ss {
                       case let .a(_), .s:
                         ()
                       case let .b(_):
                         ()
                       }
                     }
                   }
                   """

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }



  func testClosureSyntax_switchCaseLet() throws {
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

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_complexSwitch() throws {

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
                        case .null:
                          return NSNull()
                        case let .dict(dict):
                          var serializedDict = [String: Any]()
                          for (key, value) in dict {
                            serializedDict[key] = value.serialize()
                          }
                          return serializedDict
                        case let .number(number):
                          return number
                        case let .string(string):
                          return string
                        }
                      }
                    }
                   """

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }


  func testClosureSyntax_multipleCasesSameRow() throws {
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

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_caseSensitiveness() throws {
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

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_enum_oneLineCases() throws {
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

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_switch_inside_enum() throws {
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

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_switch_insideStruct() throws {
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

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)
  }

  func testClosureSyntax_enum() throws {
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
          case v

          case we
          static let  a =
          399
          static let  fdfdf =
          399
          func erk(){


          }
        }
        """

    let actual = try caseSorter.saveAsFileTemporarily(input: input)
    XCTAssertEqual(actual.description, expected)

  }

  func testClosureSyntax_switch() throws {

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

    let actual = try caseSorter.saveAsFileTemporarily(input: input)

    XCTAssertEqual(actual.description, expected)
  }


  func visitor(input: String) -> Syntax {
    let file = FileManager.default.temporaryDirectory.appendingPathComponent("deneme")
    try! input.write(to: file, atomically: true, encoding: .utf8)
    defer{
      try! FileManager.default.removeItem(at: file)
    }
    let sourceFile = try! SyntaxTreeParser.parse(file)
    return caseSorter.visit(sourceFile)
  }

  static var allTests = [
    ("testClosureSyntax_enum", testClosureSyntax_enum),
  ]
}

//enum MessageType: Int {
//  case success = 0, failure
//}

//
//enum Event {
//  case animationStarted(State, UIViewPropertyAnimator)
//  case autoExpandingFinished
//  case autoExpandingStarted(UIViewPropertyAnimator)
//  case cardTapped
//  case expandedCardSwitcherClosed
//  case scrolled(Scroll)
//  case scrollingStopped(Scroll)
//  case stackedCardsTapped
//  case stackingFinished
//  case stackingStarted(UIViewPropertyAnimator)
//  case viewWillAppear
//  case viewWillDisappear
//
//  struct Scroll {
//    let offset: CGFloat
//    let viewHeight: CGFloat
//
//    func uncollapseProgress() -> CGFloat {
//      return (-offset / (stackedHeight - collapsedHeight)) + 1
//    }
//
//    func collapseProgress() -> CGFloat {
//      return offset / (stackedHeight - collapsedHeight)
//    }
//
//    func expandProgress() -> CGFloat {
//      let expandHeight = viewHeight - stackedHeight
//      return -offset / expandHeight
//    }
//  }
//}


//public enum InitialState {
//   case loggingIn
//   case switchingCards
//   case selectingCard
//   case refreshingAccountSummary
//
//   var state: State {
//     switch self {
//     case .loggingIn, .switchingCards, .selectingCard:
//       return .expanded(nil)
//     case .refreshingAccountSummary:
//       return .stacked(nil)
//     }
//   }
//
//   var mode: Mode {
//     switch self {
//     case .loggingIn, .switchingCards, .selectingCard:
//       return .expanded
//     case .refreshingAccountSummary:
//       return .stacked
//     }
//   }
//
//   var collapseMode: CollapseMode {
//     switch self {
//     case .switchingCards, .refreshingAccountSummary:
//       return .auto(delay: nil)
//     case .selectingCard:
//       return .manual
//     case .loggingIn:
//       return .auto(delay: 1.0)
//     }
//   }
// }

//var result: Result<PaginatedResult<AnySearch<Message>.SearchResult>, WebError>? {
//  didSet {
//    switch result {
//    case let .success(result)? where result.items.isEmpty:
//      viewState = .empty
//      nextOffset = 0
//    case let .success(result)?:
//      viewState = .results(result)
//      nextOffset = result.offset
//    case let .failure(error)?:
//      viewState = .error(error)
//      nextOffset = 0
//    case .none:
//      viewState = .initial
//      nextOffset = 0
//    }
//  }
//}
