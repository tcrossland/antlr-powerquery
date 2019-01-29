package io.truedat.reduce

import io.truedat.ast.{ Expression, UnaryExpression }
import io.truedat.eval.Scope

trait UnaryExpressionReducer extends Reducible {
  this: UnaryExpression =>

  override def isReduced: Boolean =
    this.expression.isReduced

  override def isReducible: Scope => Boolean = scope =>
    this.expression.isReducible(scope)

  override def reduce: Scope => Expression = scope =>
    if (this.expression.isReducible(scope))
      this.copy(expression = this.expression.reduce(scope))
    else
      ???

  override def nextReducible: Scope => Option[Expression] = scope =>
    if (this.expression.isReducible(scope))
      this.expression.nextReducible(scope)
    else
      None
}
