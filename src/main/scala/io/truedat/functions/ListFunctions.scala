package io.truedat.functions

import io.truedat.ast._

object ListFunctions {

  val functions: Map[String, List[Expression] => Expression] = Map(
    "List.Max" -> `List.Max`.apply
  )
}

case class `List.Max`(args: List[Expression]) extends LibraryFunction
