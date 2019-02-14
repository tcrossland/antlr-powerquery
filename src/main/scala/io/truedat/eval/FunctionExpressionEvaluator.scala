package io.truedat.eval

import io.truedat.ast._

trait FunctionExpressionEvaluator extends Evaluable {
  this: FunctionExpression =>

  override def isEvaluable: Scope => Boolean = scope => {
    val e = this
    ???
  }

  override def evaluate: Scope => Expression = scope =>
    if (this.functionBody.isReduced)
      this.functionBody
    else if (this.functionBody.isReducible(scope))
      this.functionBody.reduce(scope)
    else
      ???
}
