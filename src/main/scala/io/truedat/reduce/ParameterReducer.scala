package io.truedat.reduce

import io.truedat.ast.Parameter
import io.truedat.eval.Scope

trait ParameterReducer extends Reducible {
  this: Parameter =>

  override def isReducible: Scope => Boolean = _ => false

  override def isReduced: Boolean = true
}
