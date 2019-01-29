package io.truedat.reduce

import com.typesafe.scalalogging.Logger
import io.truedat.ast.Expression
import io.truedat.eval.Scope

trait Reducible {
  val logger: Logger = Logger[Reducible]

  def isReducible: Scope => Boolean = _ => false

  def reduce: Scope => Expression = _ => {
    throw new IllegalArgumentException("No reducer for expression " + this.toString)
  }

  def isReduced: Boolean = false

  def nextReducible: Scope => Option[Expression]
}
