package io.truedat.reduce

import io.truedat.ast.{ ArgumentList, Expression, InvokeExpression }
import io.truedat.eval.Scope

trait InvokeExpressionReducer extends Reducible {
  this: InvokeExpression =>

  override def isReducible: Scope => Boolean = scope =>
    this.expression.isReducible(scope) ||
      this.argumentList.isReducible(scope) ||
      this.isEvaluable(scope)

  override def reduce: Scope => Expression = scope =>
    if (this.expression.isReducible(scope)) {
      this.copy(expression = this.expression.reduce(scope))
    } else if (this.argumentList.isReducible(scope)) {
      this.copy(argumentList = this.argumentList.reduce(scope).asInstanceOf[ArgumentList])
    } else if (this.isEvaluable(scope)) {
      this.evaluate(scope)
    } else
      ???
}
