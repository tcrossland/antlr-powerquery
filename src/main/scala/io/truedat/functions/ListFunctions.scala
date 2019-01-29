package io.truedat.functions

import io.truedat.ast.{ Expression, Transformation }

object ListFunctions {

  def max: List[Expression] => Expression = {
    case list :: _ =>
      Transformation("List.Max", list, None)
    case _ =>
      throw new IllegalArgumentException("Expected 1-4 arguments")
  }
}
