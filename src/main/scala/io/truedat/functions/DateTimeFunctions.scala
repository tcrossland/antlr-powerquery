package io.truedat.functions

import io.truedat.ast._

object DateTimeFunctions extends Functions {

  val functions: Map[String, List[Expression] => Expression] = List(
    "Date.Year",
    "DateTime.LocalNow"
  ).map(s => (s, transformation(s))).toMap
}
