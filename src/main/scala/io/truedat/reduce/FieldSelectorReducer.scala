package io.truedat.reduce

import io.truedat.ast.FieldSelector
import io.truedat.eval.Scope

trait FieldSelectorReducer extends Reducible {
  this: FieldSelector =>

  override def isReducible: Scope => Boolean = _ => false

  override def isReduced: Boolean = true
}
