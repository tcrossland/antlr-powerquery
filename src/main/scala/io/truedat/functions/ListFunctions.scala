package io.truedat.functions

import io.truedat.ast._

object ListFunctions extends Functions {

  val functions: Map[String, List[Expression] => Expression] = List(
    "List.Max"
  ).map(s => (s, transformation(s))).toMap
}
