import macros, tables, sets, typetraits


proc compImpl(f: NimNode, isSet: static[bool]): NimNode =
  result = f
  var code = result[^1]
  while code.kind in {nnkStmtList, nnkStmtListExpr}:
    if code.len > 1:
      error "expected 1 child"
    else:
      code = code[0]
  
  result[^1] = nnkStmtList.newTree(code)

  var z = code
  var isTest = false
  # echo code.lisprepr
  case code.kind:
  of nnkIfStmt:
    z = code[0][1]
    isTest = true
  else:
    discard
  
  var newCode = z
  var pre = nnkStmtList.newTree()
  var compResult = genSym(nskVar)
  var e = genSym(nskProc)
  var a = nnkForStmt.newTree(result[0], result[1], result[2], result[3])

  case z.kind:
  of nnkTableConstr:
    let key = z[0][0]
    let value = z[0][1]
    var aValue = nnkForStmt.newTree(result[0], result[1], result[2], result[3])
    a[^1] = key
    aValue[^1] = value
    let keyType = newCall(bindSym"type", a)
    let valueType = newCall(bindSym"type", aValue)
    pre = quote:
      var `compResult` = initTable[`keyType`, `valueType`]()
    newCode = quote:
      `compResult`[`key`] = `value`
  # of nnkCurly:
  # 
  else:
    if isSet:
      let child = z
      a[^1] = child
      let childType = newCall(bindSym"type", a)
      pre = quote:
        var `compResult` = initHashSet[`childType`]()
      newCode = quote:
        `compResult`.incl(`child`)
    else:
      let child = z
      a[^1] = child
      let childType = newCall(bindSym"type", a)
      pre = quote:
        var `compResult` = newSeq[`childType`]()
      newCode = quote:
        `compResult`.add(`child`)
  
  if isTest:
    result[^1][0][0][1] = newCode
  else:
    result[^1][0] = newCode

  result = quote:
    block:
      `pre`
      `result`
      `compResult`

  # echo result.repr

# Faith
macro comp*(f: untyped): untyped =
  compImpl(f, false)

macro `{}`*(c: untyped, f: untyped): untyped =
  if c.repr == "comp":
    result = compImpl(f, true)
  else:
    result = newLit("2")

when isMainModule:
  let a = {0: 0, 3: 0}.toTable()

  # let e = comp(for k, v in a: (if k == v: {k}))
  # echo e
  # let f = comp(for k, v in a: (if k == v: {k: v}))
  # echo f

  # let g = comp(for k, v in a: k + v)
  # echo g

  echo comp{for e, f in a: 0}
  echo comp[for e, f in a: 0]
  echo comp{for e, f in a: {e:f}}


