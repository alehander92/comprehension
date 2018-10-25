import unittest, comprehension, tables, sets, sequtils

{.experimental: "forLoopMacros".}

let a = {0: 0, 3: 0}.toTable()

suite "comprehension":
  test "set from table":
    let e = (for k, v in comp(a): (if k == v: {k}))
    check(e == @[0].toSet())

  test "table from table":
    let f = (for k, v in comp(a): (if k == v: {k: v}))
    check(f == {0: 0}.toTable())

  test "seq from table":
    let g = (for k, v in comp(a): k + v)
    check(g == @[0, 3])

