package io.truedat.reduce

import io.truedat.ast.{ AdditiveExpression, Expression }
import io.truedat.eval.Scope

trait AdditiveExpressionReducer extends Reducible {
  this: AdditiveExpression =>

  override def isReduced: Boolean =
    e1.isReduced && e2.isReduced && !isEvaluable(null)

  override def isReducible: Scope => Boolean = scope =>
    e1.isReducible(scope) || e2.isReducible(scope) || isEvaluable(scope)

  override def reduce: Scope => Expression = scope =>
    if (e1.isReducible(scope))
      this.copy(e1 = e1.reduce(scope))
    else if (e2.isReducible(scope))
      this.copy(e2 = e2.reduce(scope))
    else if (isEvaluable(scope))
      evaluate(scope)
    else
      ???

}
