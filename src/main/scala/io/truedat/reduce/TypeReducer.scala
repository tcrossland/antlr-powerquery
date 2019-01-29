package io.truedat.reduce

import io.truedat.ast.Type
import io.truedat.eval.Scope

trait TypeReducer extends Reducible {
  this: Type =>

  override def isReducible: Scope => Boolean = _ => false

  override def isReduced: Boolean = true
}
