package io.truedat.reduce

import io.truedat.ast.{ Expression, FieldSelector, ImplicitTargetFieldSelection }
import io.truedat.eval.Scope

trait ImplicitTargetFieldSelectionReducer extends Reducible {
  this: ImplicitTargetFieldSelection =>

  override def isReduced: Boolean =
    false

  override def isReducible: Scope => Boolean = _ =>
    true

  override def reduce: Scope => Expression = scope =>
    if (this.selection.isReducible(scope))
      this.copy(selection = this.selection.reduce(scope).asInstanceOf[FieldSelector])
    else if (this.selection.isReduced)
      this.selection
    else
      ???
}
