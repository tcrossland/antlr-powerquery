package io.truedat.reduce

import io.truedat.ast.{ Expression, Type }
import io.truedat.eval.Scope

trait TypeReducer extends Reducible {
  this: Type =>

  override def isReducible: Scope => Boolean = _ => false

  override def isReduced: Boolean = true

  override def nextReducible: Scope => Option[Expression] = _ => None
}
