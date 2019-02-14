package io.truedat.functions

import io.truedat.ast.Expression

object Functions {
  def functions: Map[String, List[Expression] => Expression] =
    TableFunctions.functions ++
      DataAccessFunctions.functions ++
      DateTimeFunctions.functions ++
      ListFunctions.functions ++
      ValueFunctions.functions
}
