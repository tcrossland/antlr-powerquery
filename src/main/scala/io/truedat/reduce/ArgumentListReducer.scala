package io.truedat.reduce

import io.truedat.ast.{ ArgumentList, Expression }
import io.truedat.eval.Scope

trait ArgumentListReducer extends Reducible {
  this: ArgumentList =>

  override def isReducible: Scope => Boolean = scope =>
    this.expressions.exists(_.isReducible(scope))

  override def reduce: Scope => Expression = scope =>
    this.expressions.indexWhere(_.isReducible(scope)) match {
      case i if i > -1 =>
        val reducedExpressions = this.expressions.splitAt(i) match {
          case (init, v :: tail) =>
            init ::: v.reduce(scope) :: tail
          case _ => ???
        }
        this.copy(expressions = reducedExpressions)
      case _ =>
        logger.warn("No expression is reducible in " + this.toString)
        throw new IllegalArgumentException("No reducible expression")
    }
}
