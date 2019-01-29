package io.truedat.functions

import io.truedat.ast._

object DateFunctions {

  def year: List[Expression] => Expression = {
    case dateTime :: Nil =>
      Function("Date.Year", dateTime)
    case _ =>
      throw new IllegalArgumentException("Expected 0 arguments")
  }
}
