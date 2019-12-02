import Foundation
import CaseSorter
import SwiftSyntax
import Basic


func fromStdin(input: String) throws -> SourceFileSyntax {
  let tempfile = try TemporaryFile(deleteOnClose: true)
  defer { tempfile.fileHandle.closeFile() }
  tempfile.fileHandle.write(input.data(using: .utf8)!)
  
  let url = URL(fileURLWithPath: tempfile.path.pathString)
  return try SyntaxTreeParser.parse(url)
}

func writeTo(path: String) throws {
  let url = URL(fileURLWithPath: path)

  let sourceFile = try SyntaxTreeParser.parse(url)

  let visit = caseSorter.visit(sourceFile)
  if !(visit == sourceFile) {
    try visit.description.write(to: url, atomically: true, encoding: .utf8)
  }
}

let caseSorter = CaseSorter()

if #available(OSX 10.11, *) {
  if let file = CommandLine.arguments.last,
    URL(fileURLWithPath: file).pathExtension == "swift"
  {

    try writeTo(path: file)

  }else if let file = CommandLine.arguments.last,
    URL(fileURLWithPath: file).hasDirectoryPath
  {
    let fileManager = FileManager()
    let en = fileManager.enumerator(atPath: URL(fileURLWithPath: file).absoluteString)

    while let element = en?.nextObject() as? String {
      if element.hasSuffix("swift"){
        print(element)
        //  writeTo(path: element)
      }
    }

  } else {
    var input = ""
    while let line = readLine() {
      print(line, to: &input)
    }

    let visit = try caseSorter.visit(fromStdin(input: input))
    let output = visit.description.trimmingCharacters(in: .whitespacesAndNewlines)

    print(output)
  }
} else {
  // Fallback on earlier versions
}



