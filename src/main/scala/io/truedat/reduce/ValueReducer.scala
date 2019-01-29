package io.truedat.reduce

import io.truedat.ast.{ Expression, Value }
import io.truedat.eval.Scope

trait ValueReducer extends Reducible {
  this: Value =>

  override def isReducible: Scope => Boolean = _ => false

  override def isReduced: Boolean = true

  override def nextReducible: Scope => Option[Expression] = _ => None
}
