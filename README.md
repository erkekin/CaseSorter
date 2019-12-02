# CaseSorter

A SPM tool to sort `enum` and `switch` cases

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

Find me on Slack @erkekin
