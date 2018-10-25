import macros, tables, sets, typetraits, sequtils

proc fixHeader(f: NimNode): NimNode =
  expectKind(f, nnkForStmt)
  expectKind(f[2], nnkCall)
  result = f
  result[2] = f[2][1]

type
  ResultComp = enum SeqComp, TableComp, SetComp


{.experimental: "forLoopMacros".}

# Faith
macro comp*(f: ForLoopStmt): untyped =
  result = fixHeader(f)
  var code = result[^1]
  if code.kind in {nnkStmtList, nnkStmtListExpr}:
    if code.len > 1:
      error "expected 1 child"
    else:
      code = code[0]
  else:
    result[^1] = nnkStmtList.newTree(code)

  var z = code
  var isTest = false
  case code.kind:
  of nnkIfStmt:
    z = code[0][1]
    isTest = true
  else:
    discard
  
  var comp = SeqComp
  var newCode = z
  var pre = nnkStmtList.newTree()
  var compResult = genSym(nskVar)
  var e = genSym(nskProc)
  var a = nnkForStmt.newTree(result[0], result[1], result[2], result[3])

  case z.kind:
  of nnkTableConstr:
    comp = TableComp
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
  of nnkCurly:
    comp = SetComp
    let child = z[0]
    a[^1] = child
    let childType = newCall(bindSym"type", a)
    pre = quote:
      var `compResult` = initSet[`childType`]()
    newCode = quote:
      `compResult`.incl(`child`)
  else:
    comp = SeqComp
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

when isMainModule:
  let a = {0: 0, 3: 0}.toTable()

  let e = (for k, v in comp(a): (if k == v: {k}))
  echo e
  let f = (for k, v in comp(a): (if k == v: {k: v}))
  echo f

  let g = (for k, v in comp(a): k + v)
  echo g
