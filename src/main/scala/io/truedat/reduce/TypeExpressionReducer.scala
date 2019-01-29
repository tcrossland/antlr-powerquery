package io.truedat.reduce

import io.truedat.ast.{ Expression, TypeExpression }
import io.truedat.eval.Scope

trait TypeExpressionReducer extends Reducible {
  this: TypeExpression =>

  override def reduce: Scope => Expression =
    _ => this.t

  override def isReducible: Scope => Boolean = _ => true

  override def isReduced: Boolean = false
}
