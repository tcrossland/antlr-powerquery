package io.truedat.functions

import io.truedat.ast._

object DateTimeFunctions {

  def localNow: List[Expression] => Expression = {
    case Nil =>
      DateTimeLocalNow
    case _ =>
      throw new IllegalArgumentException("Expected 0 arguments")
  }
}
