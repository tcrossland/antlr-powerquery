package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope

trait FunctionExpressionReducer extends Reducible {
  this: FunctionExpression =>

  override def isReduced: Boolean =
    this.parameterList.isReduced && this.functionBody.isReduced

  override def isReducible: Scope => Boolean = scope =>
    this.functionBody.isReducible(scope)

  override def reduce: Scope => Expression = scope => {
    this.copy(functionBody = this.functionBody.reduce(scope))
  }
}
