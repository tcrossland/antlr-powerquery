package io.truedat.reduce

import io.truedat.ast.{ Expression, ItemList }
import io.truedat.eval.Scope

trait ItemListReducer extends Reducible {
  this: ItemList =>

  override def isReduced: Boolean =
    this.list.forall(_.isReduced)

  override def isReducible: Scope => Boolean = scope =>
    this.list.exists(_.isReducible(scope))

  override def reduce: Scope => Expression = scope =>
    this.list.indexWhere(_.isReducible(scope)) match {
      case i if i > -1 =>
        val reducedItems = this.list.splitAt(i) match {
          case (init, v :: tail) =>
            init ::: v.reduce(scope) :: tail
          case _ => ???
        }
        this.copy(list = reducedItems)
      case _ =>
        logger.warn("No item is reducible in " + this.toString)
        throw new IllegalArgumentException("No reducible items")
    }

  override def nextReducible: Scope => Option[Expression] = scope =>
    this.list.find(_.isReducible(scope)).flatMap(_.nextReducible(scope))

}
