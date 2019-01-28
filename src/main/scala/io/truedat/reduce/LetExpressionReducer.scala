package io.truedat.reduce

import io.truedat.ast.{ Expression, LetExpression, VariableList }
import io.truedat.eval.Scope

trait LetExpressionReducer extends Reducible {
  this: LetExpression =>

  def getScope: Scope => Scope = parentScope => Scope.extend(parentScope, this)

  override def isReducible: Scope => Boolean = parentScope => {
    val scope = getScope(parentScope)
    this.variableList.isReducible(scope) ||
      this.variableList.isReduced && this.expression.isReducible(scope)
  }

  override def reduce: Scope => Expression = parentScope => {
    val scope = getScope(parentScope)
    if (this.variableList.isReducible(scope))
      this.copy(variableList = this.variableList.reduce(scope).asInstanceOf[VariableList])
    else if (this.variableList.isReduced && this.expression.isReducible(scope))
      this.expression.reduce(scope)
    else {
      logger.warn(this.toString)
      ???
    }
  }
}
