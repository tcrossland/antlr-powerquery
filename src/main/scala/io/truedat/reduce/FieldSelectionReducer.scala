package io.truedat.reduce

import io.truedat.ast.{ Expression, FieldSelection, FieldSelector }
import io.truedat.eval.Scope

trait FieldSelectionReducer extends Reducible {
  this: FieldSelection =>

  override def isReduced: Boolean =
    this.expression.isReduced &&
      this.selection.isReduced

  override def isReducible: Scope => Boolean = scope =>
    this.expression.isReducible(scope) ||
      this.selection.isReducible(scope) ||
      this.isEvaluable(scope)

  override def reduce: Scope => Expression = scope =>
    if (this.expression.isReducible(scope))
      this.copy(expression = this.expression.reduce(scope))
    else if (this.selection.isReducible(scope))
      this.copy(selection = this.selection.reduce(scope).asInstanceOf[FieldSelector])
    else if (this.isEvaluable(scope))
      this.evaluate(scope)
    else
      ???
}
