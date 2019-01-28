package io.truedat.reduce

import io.truedat.ast.Value
import io.truedat.eval.Scope

trait ValueReducer extends Reducible {
  this: Value =>

  override def isReducible: Scope => Boolean = _ => false

  override def isReduced: Boolean = true
}
