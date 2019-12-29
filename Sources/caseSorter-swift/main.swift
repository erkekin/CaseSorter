import Foundation
import CaseSorter
import SwiftSyntax

let caseSorter = CaseSorter()

func writeTo(path: String) throws {
  let url = URL(fileURLWithPath: path)

  let sourceFile = try SyntaxTreeParser.parse(url)

  let visit = caseSorter.visit(sourceFile)
  if !(visit == sourceFile) {
    try visit.description.write(to: url, atomically: true, encoding: .utf8)
  }
}

if CommandLine.arguments.count > 0 {
  try Set(
    CommandLine.arguments
      .filter{URL(fileURLWithPath: $0).pathExtension == "swift"}
  )
    .forEach{try writeTo(path: $0)}
} else { // source code into standart input, used by automator script
  var input = ""
  while let line = readLine() {
    print(line, to: &input)
  }
  let syntax = try caseSorter.saveAsFileTemporarily(input: input)
  let output = syntax.description
  print(output)
}
