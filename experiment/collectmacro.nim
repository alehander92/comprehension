import macros, sets, tables

type
   CollectBuilder = ref object
      valueType, keyType: NimNode

proc transLastStmt(n, res, callConstr: NimNode; b: CollectBuilder): NimNode =
   # Looks for the last statement of the last statement, etc...
   case n.kind
   of nnkStmtList, nnkStmtListExpr, nnkBlockStmt, nnkBlockExpr,
         nnkWhileStmt,
         nnkForStmt, nnkIfExpr, nnkIfStmt, nnkTryStmt, nnkCaseStmt,
         nnkElifBranch, nnkElse, nnkElifExpr:
      result = copyNimTree(n)
      let prevKey = copyNimTree(n)
      let prevVal = copyNimTree(n)
      if n.len >= 1:
         result[^1] = transLastStmt(n[^1], res, callConstr, b)
         prevVal[^1] = b.valueType
         prevKey[^1] = b.keyType
         b.keyType = prevKey
         b.valueType = prevVal
   else:
      if n.kind == nnkTableConstr and n.len == 1 and n[0].kind == nnkExprColonExpr:
         expectLen(n[0], 2)
         let key = n[0][0]
         let value = n[0][1]
         b.keyType = key
         b.valueType = value
         callConstr.add(bindSym"initTable", newCall(bindSym"typeof", newEmptyNode()),
            newCall(bindSym"typeof", newEmptyNode()))
         template adder(res, k, v) =
            res[k] = v
         result = getAst(adder(res, key, value))
      elif n.kind == nnkCurly:
         expectLen(n, 1)
         let value = n[0]
         b.valueType = value
         callConstr.add(bindSym"initSet", newCall(bindSym"typeof", newEmptyNode()))
         template adder(res, v) =
            res.incl(v)
         result = getAst(adder(res, value))
      else:
         let value = n
         b.valueType = value
         callConstr.add(bindSym"newSeq", newCall(bindSym"typeof", newEmptyNode()))
         template adder(res, v) =
            res.add(v)
         result = getAst(adder(res, value))

macro collect*(body): untyped =
   # analyse the body, find the deepest expression 'it' and replace it via
   # 'result.add it'
   let b = CollectBuilder()
   let res = genSym(nskVar, "collectResult")
   let callConstr = newNimNode(nnkBracketExpr)
   let resBody = transLastStmt(body, res, callConstr, b)
   if callConstr.len == 3:
      callConstr[1][1] = b.keyType
      callConstr[2][1] = b.valueType
   else:
      callConstr[1][1] = b.valueType
   let tempVar = newTree(nnkVarSection,
      newTree(nnkIdentDefs, res, newEmptyNode(), newTree(nnkCall, callConstr)))
   result = newTree(nnkStmtListExpr, tempVar, resBody, res)
   echo repr(result)

when isMainModule:
   import tables, sets

   var data = {2: "bird", 5: "word"}.toTable
   let x = collect:
      for k, v in data:
         if k mod 2 == 0:
            {k: v}
   echo x
