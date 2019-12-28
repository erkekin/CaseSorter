# CaseSorter

A SPM tool to sort `enum` and `switch` cases.


## Usage

Just select a bunch of text in Xcode and right click > Services > `Sort cases` 🎊
or
```
$ ~/.casesorter/release/caseSorter-swift AnySwiftFile.swift
```
or
```
$ cat AnySwiftFile.swift | ~/.casesorter/release/caseSorter-swift
```
## Example

Input
```
 switch aComplexCase {
   case .sa, let .da(_):
     ()
   case .s, .a:
     ()
 }
``` 

Output

```
 switch aComplexCase {
   case .a, .s:
     ()
   case let .da(_), .sa:
     ()
 }
```
## Install
To install with Automator tool run the shell script below
```
git clone https://stash.mps.intra.aexp.com/scm/cas/casesorter-swift.git
cd casesorter-swift
swift build -c release --build-path ~/.casesorter
open Sortcases.workflow
```
This will prompt you a dialog to confirm the installation of an automator script. If you accept it, you can select a code piece inside Xcode and right click > Services > `Sort cases`  to sort enum and switch cases.

You can assign a keyboard shortcut to the automator script from Settings > Keyboard > Shortcuts > Services >  `Sort cases` 

Please see tests and feel free to contribute.

## Limitations
* Shouldn't sort Result<T, Error> cases

Please see tests

Find me on Twitter @erkekin
