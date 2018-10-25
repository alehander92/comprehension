# comprehension

A nim library providing comprehensions: 

* set comprehension `(for k, v in comp(a): (if k == v: {k}))`
* table comprehensions `(for k, v in comp(a): (if k == v: {k: v}))`
* seq comprehensions `(for k, v in comp(a): k + v)`

# Implementation

Based on forLoop macros, requires `{.experimental: "forLoopMacros".}` to be used for now


Type resolution based on Araq's [collect macro](https://github.com/nim-lang/Nim/blob/devel/tests/macros/tcollect.nim)
