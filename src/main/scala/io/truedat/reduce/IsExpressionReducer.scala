package io.truedat.reduce

import io.truedat.ast.{ Expression, IsExpression }
import io.truedat.eval.Scope

trait IsExpressionReducer extends Reducible {
  this: IsExpression =>

  override def isReduced: Boolean = false

  override def isReducible: Scope => Boolean = _ =>
    true

  override def reduce: Scope => Expression = _ =>
    this.expression

  override def nextReducible: Scope => Option[Expression] = _ =>
    Some(this)
}
