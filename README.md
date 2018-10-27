# comprehension

A nim library providing comprehensions: 

* set comprehension `comp{for k, v in comp(a): (if k == v: k)}`
* table comprehensions `comp{for k, v in comp(a): (if k == v: {k: v})}`
* seq comprehensions `comp[for k, v in comp(a): k + v]`

# Implementation

Type resolution based on Araq's [collect macro](https://github.com/nim-lang/Nim/blob/devel/tests/macros/tcollect.nim)
