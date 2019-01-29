package io.truedat.reduce

import io.truedat.ast.{ Expression, ItemSelection }
import io.truedat.eval.Scope

trait ItemSelectionReducer extends Reducible {
  this: ItemSelection =>

  override def isReduced: Boolean =
    this.expression.isReduced &&
      this.itemSelector.isReduced

  override def isReducible: Scope => Boolean = scope =>
    this.expression.isReducible(scope) ||
      this.itemSelector.isReducible(scope) ||
      this.isEvaluable(scope)

  override def reduce: Scope => Expression = scope =>
    if (this.expression.isReducible(scope))
      this.copy(expression = this.expression.reduce(scope))
    else if (this.itemSelector.isReducible(scope))
      this.copy(itemSelector = this.itemSelector.reduce(scope))
    else if (this.isEvaluable(scope))
      this.evaluate(scope)
    else
      ???
}
