package io.truedat.reduce

import io.truedat.ast.{ Expression, Variable }
import io.truedat.eval.Scope

trait VariableReducer extends Reducible {
  this: Variable =>

  override def isReduced: Boolean = this.expression.isReduced

  override def isReducible: Scope => Boolean = scope => this.expression.isReducible(scope)

  override def reduce: Scope => Expression = scope =>
    this.copy(
      expression = this.expression.reduce(scope)
    )
}
