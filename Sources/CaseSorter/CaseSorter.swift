import SwiftSyntax
import Foundation
import Cocoa
import AppKit

enum Trial {
  case b
  case z(String)
  case a
}

enum deneme{
  case z
  case a
}

public class CaseSorter: SyntaxRewriter {

  public func saveAsFileTemporarily(input: String) throws -> Syntax {
    var file: URL
    if #available(OSX 10.12, *) {
      file = FileManager.default.temporaryDirectory
    } else {
      file = URL(fileURLWithPath: NSTemporaryDirectory())
    }
    file = file.appendingPathComponent("deneme")
    try input.write(to: file, atomically: true, encoding: .utf8)
    defer{
      try? FileManager.default.removeItem(at: file)
    }

    let sourceFile = try SyntaxTreeParser.parse(file)
    return visit(sourceFile)
  }

  public override func visit(_ node: CaseItemListSyntax) -> Syntax {
    super.visit(node.alphaSorted)
  }

  public override func visit(_ node: EnumCaseElementListSyntax) -> Syntax {
    super.visit(node.alphaSorted)
  }

  public override func visit(_ node: EnumDeclSyntax) -> DeclSyntax {
    super.visit(node.alphaSorted)
  }

  public override func visit(_ node: SwitchStmtSyntax) -> StmtSyntax {
    super.visit(node.alphaSorted)
  }
}

protocol AlphaSortable {
  var alphaSorted: Self {get}
}

extension CaseItemListSyntax: AlphaSortable {
  func getCaseID(_ syntax: Syntax) -> String {
    guard let of = syntax as? CaseItemSyntax else {
      return syntax.description.trimmingCharacters(in: .whitespaces)
    }

    let output =  of.pattern.children
      .compactMap{$0 as? ExpressionPatternSyntax}
      .compactMap{$0.expression }
      .flatMap{$0.children}
      .compactMap{$0 as? MemberAccessExprSyntax}
      .compactMap{$0.description}
      .first ?? of.description.trimmingCharacters(in: .whitespaces)
    return output
  }

  var alphaSorted: CaseItemListSyntax {
    let a = (children
      .sorted{
        getCaseID($1).caseInsensitiveCompare(getCaseID($0)) == .orderedDescending
      } as! [CaseItemSyntax])
      .enumerated()
      .map{
        $1.withTrailingComma(
          (numberOfChildren == $0 + 1)
            ? nil : SyntaxFactory.makeCommaToken().withTrailingTrivia(.spaces(1))
        )
    }

    return SyntaxFactory.makeCaseItemList(a)
  }
}

extension EnumCaseElementListSyntax: AlphaSortable {
  var alphaSorted: EnumCaseElementListSyntax {

    let a = (children
      .sorted{
        $1.description
          .trimmingCharacters(in: .whitespaces)
          .caseInsensitiveCompare(
            $0.description
              .trimmingCharacters(in: .whitespaces)
          ) == .orderedDescending
      } as! [EnumCaseElementSyntax])
      .enumerated()
      .map{
        $1.withTrailingComma((numberOfChildren == $0 + 1) ? nil : SyntaxFactory.makeCommaToken().withTrailingTrivia(.spaces(1)))
    }

    return SyntaxFactory.makeEnumCaseElementList(a)
  }
}

extension SwitchStmtSyntax: AlphaSortable {
  func getCaseID(_ syntax: Syntax) -> String {
    guard let of = syntax as? SwitchCaseSyntax else {
      return syntax.description.trimmingCharacters(in: .whitespaces)
    }
    let children = of.children.compactMap{$0}
    if children.contains(where: {$0 is SwitchDefaultLabelSyntax}) {
      return "~~~" // to keep default case always at the bottom
    }

    let pattern = children
      .compactMap{$0 as? SwitchCaseLabelSyntax}
      .flatMap{$0.caseItems.alphaSorted}
      .compactMap{$0.pattern}
      .first

    var output: String

    switch pattern {
    case is ValueBindingPatternSyntax:
      let a = (pattern as? ValueBindingPatternSyntax)?
        .children
        .compactMap{$0 as? ExpressionPatternSyntax}
        .compactMap{$0.expression }
        .flatMap{$0.children}
        .compactMap{$0 as? MemberAccessExprSyntax}
        .compactMap{$0.name}
        .first
      output = a?.description ?? "NOT"
    case is ExpressionPatternSyntax:
      let a = pattern?
        .children
        .compactMap{$0 as? TupleExprSyntax}
        .flatMap{$0.elementList}
        .compactMap{$0.expression}
        .first
      switch a {
      case is DiscardAssignmentExprSyntax:
        output = (a as! DiscardAssignmentExprSyntax).description
      case is MemberAccessExprSyntax:
        let b = (a as! MemberAccessExprSyntax).name
        output = b.text
      default:
        output = syntax.description
      }
    default:
      output = syntax.description
    }

    return output.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  var alphaSorted: SwitchStmtSyntax {
    let switchCaseListSyntax = cases
      .sorted{
        getCaseID($1).caseInsensitiveCompare(getCaseID($0)) == .orderedDescending
    }

    return withCases(
      SyntaxFactory.makeSwitchCaseList(switchCaseListSyntax)
    )
  }
}

extension EnumDeclSyntax {
  func getCaseID(_ syntax: Syntax) -> String {
    guard let of = syntax as? MemberDeclListItemSyntax else {
      return syntax.description.trimmingCharacters(in: .whitespaces)
    }

    let pattern = of.children
      .compactMap{$0 as? EnumCaseDeclSyntax}
      .flatMap{$0.elements.alphaSorted}
      .compactMap{$0.identifier}
      .first

    return pattern?.text ?? syntax.description.trimmingCharacters(in: .whitespaces)
  }

  var alphaSorted: EnumDeclSyntax {
    let enumCaseDecls = members
      .members
      .filter{$0.decl is EnumCaseDeclSyntax}

    let otherDecls = members
         .members
         .filter{!($0.decl is EnumCaseDeclSyntax)}

    let sortedEnumCaseDecls = enumCaseDecls
      .sorted{
        getCaseID($1).caseInsensitiveCompare(getCaseID($0)) == .orderedDescending
    }

    return withMembers(SyntaxFactory.makeMemberDeclBlock(
      leftBrace: members.leftBrace,
      members: SyntaxFactory.makeMemberDeclList(sortedEnumCaseDecls + otherDecls),
      rightBrace: members.rightBrace
    ))
  }
}
