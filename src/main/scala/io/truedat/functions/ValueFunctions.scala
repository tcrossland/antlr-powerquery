package io.truedat.functions

import io.truedat.ast._

object ValueFunctions extends Functions {

  val functions: Map[String, List[Expression] => Expression] = List(
    "Value.NativeQuery"
  ).map(s => (s, transformation(s))).toMap
}
