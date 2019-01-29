package io.truedat.reduce

import io.truedat.ast.IntrinsicFunction
import io.truedat.eval.Scope

trait IntrinsicFunctionReducer extends Reducible {
  this: IntrinsicFunction =>

  override def isReducible: Scope => Boolean = _ => false

  override def isReduced: Boolean = true
}
