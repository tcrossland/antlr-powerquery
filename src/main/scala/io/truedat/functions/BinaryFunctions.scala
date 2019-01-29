package io.truedat.functions

import io.truedat.ast._

object BinaryFunctions extends Functions {

  val functions: Map[String, List[Expression] => Expression] = List(
    "Binary.Decompress",
    "Binary.FromText"
  ).map(s => (s, transformation(s))).toMap
}
