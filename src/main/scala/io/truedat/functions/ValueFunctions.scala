package io.truedat.functions

import io.truedat.ast._

object ValueFunctions {
  val functions: Map[String, List[Expression] => Expression] = Map(
    "Value.NativeQuery" -> `Value.NativeQuery`.apply
  )
}

case class `Value.NativeQuery`(args: List[Expression]) extends LibraryFunction