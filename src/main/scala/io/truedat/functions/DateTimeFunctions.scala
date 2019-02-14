package io.truedat.functions

import io.truedat.ast._

object DateTimeFunctions {

  val functions: Map[String, List[Expression] => Expression] = Map(
    "Date.Year" -> `Date.Year`.apply,
    "DateTime.LocalNow" -> `DateTime.LocalNow`.apply
  )
}

case class `Date.Year`(args: List[Expression]) extends LibraryFunction
case class `DateTime.LocalNow`(args: List[Expression]) extends LibraryFunction