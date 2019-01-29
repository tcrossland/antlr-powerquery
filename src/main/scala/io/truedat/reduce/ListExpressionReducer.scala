package io.truedat.reduce

import io.truedat.ast.{ Expression, ItemList, ListExpression }
import io.truedat.eval.Scope

trait ListExpressionReducer extends Reducible {
  this: ListExpression =>

  override def isReduced: Boolean = this.list.isReduced

  override def isReducible: Scope => Boolean = scope =>
    this.list.isReducible(scope)

  override def reduce: Scope => Expression = scope =>
    this.copy(list = this.list.reduce(scope).asInstanceOf[ItemList])

  override def nextReducible: Scope => Option[Expression] = scope =>
    this.list.nextReducible(scope)
}
