import SwiftSyntax
import Foundation
import SPMUtility
import Basic
import Cocoa
import AppKit

public class CaseSorter: SyntaxRewriter {

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
      return syntax.description.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    let output =  of.pattern.children
      .compactMap{$0 as? ExpressionPatternSyntax}
      .compactMap{$0.expression }
      .flatMap{$0.children}
      .compactMap{$0 as? MemberAccessExprSyntax}
      .compactMap{$0.description}
      .first ?? of.description.trimmingCharacters(in: .whitespacesAndNewlines)
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
          ?
            nil
          :
            SyntaxFactory.makeCommaToken().withTrailingTrivia(.spaces(1))
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
          .trimmingCharacters(in: .whitespacesAndNewlines)
          .caseInsensitiveCompare(
            $0.description
              .trimmingCharacters(in: .whitespacesAndNewlines)
          ) == .orderedDescending
      } as! [EnumCaseElementSyntax])
      .enumerated()
      .map{
        $1.withTrailingComma( (numberOfChildren == $0 + 1) ? nil : SyntaxFactory.makeCommaToken().withTrailingTrivia(.spaces(1)))
    }

    return SyntaxFactory.makeEnumCaseElementList(a)
  }
}

extension SwitchStmtSyntax: AlphaSortable {
  func getCaseID(_ syntax: Syntax) -> String {
    guard let of = syntax as? SwitchCaseSyntax else {
      return syntax.description.trimmingCharacters(in: .whitespacesAndNewlines)
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

    let output: String

    switch pattern {
    case is ValueBindingPatternSyntax:
      let a = (pattern as? ValueBindingPatternSyntax)?
        .children
        .compactMap{$0 as? ExpressionPatternSyntax}
        .compactMap{$0.expression }
        .flatMap{$0.children}
        .compactMap{$0 as? MemberAccessExprSyntax}
        .compactMap{$0.description}
        .first
      output = a?.description ?? of.description
    case is ExpressionPatternSyntax:
      output = pattern?.description ?? of.description
    default:
      output = of.description
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
        return syntax.description
      }

      let pattern = of.children
        .compactMap{$0 as? EnumCaseDeclSyntax}
        .flatMap{$0.elements.alphaSorted}
        .compactMap{$0.identifier}
        .first

    return (pattern?.description ?? syntax.description)
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }


  var alphaSorted: EnumDeclSyntax {
    let a = members.members
      .sorted{
        getCaseID($1).caseInsensitiveCompare(getCaseID($0)) == .orderedDescending
    }

    return withMembers(SyntaxFactory.makeMemberDeclBlock(
      leftBrace: members.leftBrace,
      members: SyntaxFactory.makeMemberDeclList(a),
      rightBrace: members.rightBrace
    ))
  }
}
