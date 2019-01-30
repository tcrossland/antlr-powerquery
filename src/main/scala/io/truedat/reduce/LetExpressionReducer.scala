package io.truedat.reduce

import io.truedat.ast.{ Expression, LetExpression, VariableList }
import io.truedat.eval.Scope

trait LetExpressionReducer extends Reducible {
  this: LetExpression =>

  def getScope: Scope => Scope = parentScope => Scope.extend(parentScope, this)

  override def isReduced: Boolean =
    this.variableList.isReduced &&
      this.expression.isReduced

  override def isReducible: Scope => Boolean = parentScope => {
    val scope = getScope(parentScope)
    this.variableList.isReducible(parentScope) ||
      this.variableList.isReduced && this.expression.isReducible(scope)
  }

  override def reduce: Scope => Expression = parentScope => {
    val scope = getScope(parentScope)
    if (this.variableList.isReducible(parentScope))
      this.copy(variableList = this.variableList.reduce(parentScope).asInstanceOf[VariableList])
    else if (this.variableList.isReduced && this.expression.isReducible(scope))
      this.expression.reduce(scope)
    else
      ???
  }

  override def nextReducible: Scope => Option[Expression] = parentScope => {
    val scope = getScope(parentScope)
    if (this.variableList.isReducible(parentScope))
      this.variableList.nextReducible(parentScope)
    else if (this.variableList.isReduced && this.expression.isReducible(scope))
      Some(this)
    else
      None
  }
}
