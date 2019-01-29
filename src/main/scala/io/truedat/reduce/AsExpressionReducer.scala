package io.truedat.reduce

import io.truedat.ast.{ AsExpression, Expression }
import io.truedat.eval.Scope

trait AsExpressionReducer extends Reducible {
  this: AsExpression =>

  override def isReduced: Boolean = false

  override def isReducible: Scope => Boolean = _ =>
    true

  override def reduce: Scope => Expression = _ =>
    this.expression
}
