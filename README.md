# CaseSorter
 
A SPM tool to sort `enum` and `switch` cases. This Swift project automatically checks proposed changes in Pull Requests, sorts `enum` and `switch` cases and creates a new Pull Request along with sorted changes.

## Usage

Just select a bunch of text in Xcode and right click > Services > `Sortcases`  🎊

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
cd CaseSorter
swift build -c release --build-path ~/.casesorter
open Sortcases.workflow
```
This will prompt you a dialog to confirm the installation of an automator script. If you accept it, you can select a code piece inside Xcode and right click > Services > `Sort cases`  to sort enum and switch cases.

You can assign a keyboard shortcut to the automator script from Settings > Keyboard > Shortcuts > Services >  `Sort cases` 

Please see tests and feel free to contribute.

## GitHub Actions

### Installation
```
    - name: Changed Files Exporter
      uses: futuratrepadeira/changed-files@v3.0.0
      with:
        repo-token: ${{ secrets.GITHUB_TOKEN }}
```

### Example
You can add this action to your Swift project and sort changed files of a pull request. It even creates a new pull request along with Swift enums sorted.
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
    - name: Changed Files Exporter
      uses: futuratrepadeira/changed-files@v3.0.0
      with:
        repo-token: ${{ secrets.GITHUB_TOKEN }}
      id: files
    - name: Automatic Sort Cases
      uses: erkekin/CaseSorter@master
      with: 
        files: "${{ steps.files.outputs.files_updated }} ${{ steps.files.outputs.files_created }}"
        repo-token: ${{ secrets.GITHUB_TOKEN }}
    - name: Create Pull Request
      uses: peter-evans/create-pull-request@v1
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        commit-message: enum cases sorted
        title: Case Sorter in Action
        body: This is an auto-generated PR with fixes by case sorter tool.
        labels: sort, automated pr, enum
        branch: ${{ steps.vars.outputs.branch-name }}
        branch-suffix: none

```

Please see tests.

Find me on Twitter @erkekin
