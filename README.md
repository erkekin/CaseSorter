# CaseSorter

A SPM tool to sort `enum` and `switch` cases

## Example

input
```
             switch erk {
               case .sa, let .da(_):
                 ()
               case .s, .a:
                 ()
             }
``` 

output

```
                switch erk {
                  case .a, .s:
                    ()
                  case let .da(_), .sa:
                    ()
                }
```


## Install
To install with Automator tool run the shell script below
```
git clone https://eekin@stash.mps.intra.aexp.com/scm/cas/casesorter-swift.git
cd casesorter-swift
sh install.sh
```
