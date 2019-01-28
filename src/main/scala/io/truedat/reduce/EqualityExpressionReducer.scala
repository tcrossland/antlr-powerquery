package io.truedat.reduce

import io.truedat.ast.{ EqualityExpression, Expression }
import io.truedat.eval.Scope

trait EqualityExpressionReducer extends Reducible {
  this: EqualityExpression =>

  override def isReducible: Scope => Boolean = scope =>
    e1.isReducible(scope) || e2.isReducible(scope)

  override def isReduced: Boolean =
    e1.isReduced && e2.isReduced

  override def reduce: Scope => Expression = scope =>
    if (e1.isReducible(scope))
      this.copy(e1 = e1.reduce(scope))
    else if (e2.isReducible(scope))
      this.copy(e2 = e2.reduce(scope))
    else
      ???
}
