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

if let file = CommandLine.arguments.last,
  URL(fileURLWithPath: file).pathExtension == "swift" {
  try writeTo(path: file)
} else {
  var input = ""
  while let line = readLine() {
    print(line, to: &input)
  }
  let syntax = try caseSorter.saveAsFileTemporarily(input: input)
  let output = syntax.description.trimmingCharacters(in: .whitespacesAndNewlines)
  print(output)
}
