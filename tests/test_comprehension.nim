import unittest, comprehension, tables, sets

{.experimental: "forLoopMacros".}

let a = {0: 0, 3: 0}.toTable()
let b = {0: 0, 3: 0}.toOrderedTable()
let c = {3: 0, 0: 0}.toOrderedTable()

suite "comprehension":
  test "set from table":
    let e = comp{for k, v in a: (if k == v: k)}
    check(e == @[0].toHashSet())

  test "table from table":
    let f = comp{for k, v in a: (if k == v: {k: v})}
    check(f == {0: 0}.toTable())

  test "seq from table":
    let g = comp[for k, v in a: k + v]
    check(g in @[@[0, 3], @[3, 0]])

  test "seq from ordered table":
    let g = comp[for k, v in b: k + v]
    check(g == @[0, 3])
    let h = comp[for k, v in c: k + v]
    check(h == @[3, 0])
