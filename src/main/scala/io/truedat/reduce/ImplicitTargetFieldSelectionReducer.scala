package io.truedat.reduce

import io.truedat.ast.{ Expression, FieldSelector, ImplicitTargetFieldSelection }
import io.truedat.eval.Scope

trait ImplicitTargetFieldSelectionReducer extends Reducible {
  this: ImplicitTargetFieldSelection =>

  override def isReducible: Scope => Boolean = scope =>
      this.selection.isReducible(scope)

  override def reduce: Scope => Expression = scope =>
    if (this.selection.isReducible(scope))
      this.copy(selection = this.selection.reduce(scope).asInstanceOf[FieldSelector])
    else
      ???
}
