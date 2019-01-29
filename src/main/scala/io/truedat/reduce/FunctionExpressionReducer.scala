package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope

trait FunctionExpressionReducer extends Reducible {
  this: FunctionExpression =>

  def getScope: Scope => Scope = parentScope => Scope.extend(parentScope, this)

  override def isReduced: Boolean =
    this.parameterList.isReduced && this.functionBody.isReduced

  override def isReducible: Scope => Boolean = parentScope => {
    val scope = getScope(parentScope)
    this.parameterList.isReducible(scope) || this.functionBody.isReducible(scope)
  }

  override def reduce: Scope => Expression = parentScope => {
    val scope = getScope(parentScope)
    if (this.parameterList.isReducible(scope))
      this.copy(parameterList = this.parameterList.reduce(scope).asInstanceOf[ParameterList])
    else if (this.functionBody.isReducible(scope))
      this.copy(functionBody = this.functionBody.reduce(scope))
    else
      ???
  }
}
