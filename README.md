# CaseSorter
 
A SPM tool to sort `enum` and `switch` cases. This Swift project automatically checks proposed changes in Pull Requests, sorts its `enum` and `switch` cases and creates a new Pull Request with sorted changes.

## Usage

Just select a bunch of text in Xcode and right click > Services > `Sort cases` 🎊

or with CLI arguments (support mutliple swift files)
```
$ ~/.casesorter/release/caseSorter-swift AnySwiftFile.swift
```
or with `stdinput`
```
$ cat AnySwiftFile.swift | ~/.casesorter/release/caseSorter-swift
```

## Examples

#### Input

```
 switch aComplexCase {
   case .sa, let .da(_):
     ()
   case .s, .a:
     ()
 }
``` 

#### Output

```
 switch aComplexCase {
   case .a, .s:
     ()
   case let .da(_), .sa:
     ()
 }
```

## Install
To install with Automator tool, run the shell script below.
```
git clone https://github.com/erkekin/CaseSorter.git
cd casesorter-swift
swift build -c release --build-path ~/.casesorter
open Sortcases.workflow
```
This will prompt you a dialog to confirm the installation of an automator script. If you accept it, you can select a code piece inside Xcode and right click > Services > `Sort cases`  to sort enum and switch cases.

You can assign a keyboard shortcut to the automator script from Settings > Keyboard > Shortcuts > Services >  `Sort cases` 

Please see tests and feel free to contribute.

## GitHub Actions

### Installation
```
- name: Sort Swift Enum Cases
  uses: erkekin/CaseSorter@v1
```

### Example
You can add this action to your swift project and sort changed files in a pull request. It even creates a new pull request with swift enums sorted.
```
on: pull_request
name: sort-cases
jobs:
  sortcases:
    name: Sort
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@master
      with: 
        ref: ${{ github.head_ref }}
    - name: Automatic Sort Cases
      uses: erkekin/CaseSorter@master
      with: 
        files: Sources/CaseSorter/CaseSorter.swift
      id: download-sorter
    - name: Create Pull Request
      uses: peter-evans/create-pull-request@v1
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        commit-message: enum cases sorted
        title: Case Sorter in Action
        body: This is an auto-generated PR with fixes by case sorter tool.
        labels: sort, automated pr
        branch: ${{ steps.vars.outputs.branch-name }}
        branch-suffix: none
```

## Limitations
* Shouldn't sort Result<T, Error> cases

Please see `tests`

Find me on Twitter @erkekin
