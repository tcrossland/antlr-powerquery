package io.truedat.reduce

import io.truedat.ast.{ Expression, Field }
import io.truedat.eval.Scope

trait FieldReducer extends Reducible {
  this: Field =>

  override def isReducible: Scope => Boolean = scope =>
    this.expression.isReducible(scope)

  override def isReduced: Boolean =
    this.expression.isReduced

  override def reduce: Scope => Expression = scope =>
    this.copy(expression = this.expression.reduce(scope))
}
