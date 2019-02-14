package io.truedat.functions

import io.truedat.ast._

object BinaryFunctions {
  val functions: Map[String, List[Expression] => Expression] = Map(
    "Binary.Decompress" -> `Binary.Decompress`.apply,
    "Binary.FromText" -> `Binary.FromText`.apply
  )
}

case class `Binary.Decompress`(args: List[Expression]) extends LibraryFunction
case class `Binary.FromText`(args: List[Expression]) extends LibraryFunction
