package io.truedat.reduce

import io.truedat.ast.{ Expression, OptionalItemSelection }
import io.truedat.eval.Scope

trait OptionalItemSelectionReducer extends Reducible {
  this: OptionalItemSelection =>

  override def isReduced: Boolean =
    this.expression.isReduced &&
      this.itemSelector.isReduced

  override def isReducible: Scope => Boolean = scope =>
    this.expression.isReducible(scope) ||
      this.itemSelector.isReducible(scope)

  override def reduce: Scope => Expression = scope =>
    if (this.expression.isReducible(scope))
      this.copy(expression = this.expression.reduce(scope))
    else if (this.itemSelector.isReducible(scope))
      this.copy(itemSelector = this.itemSelector.reduce(scope))
    else
      ???

  override def nextReducible: Scope => Option[Expression] = scope =>
    if (this.expression.isReducible(scope))
      this.expression.nextReducible(scope)
    else if (this.itemSelector.isReducible(scope))
      this.itemSelector.nextReducible(scope)
    else
      None
}
