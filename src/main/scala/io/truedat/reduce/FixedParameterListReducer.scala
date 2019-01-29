package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope

trait FixedParameterListReducer extends Reducible {
  this: FixedParameterList =>

  override def isReducible: Scope => Boolean = scope =>
    this.parameters.exists(_.isReducible(scope))

  override def isReduced: Boolean =
    this.parameters.forall(_.isReduced)

  override def reduce: Scope => Expression = scope =>
    this.parameters.indexWhere(_.isReducible(scope)) match {
      case i if i > -1 =>
        val reducedExpressions = this.parameters.splitAt(i) match {
          case (init, v :: tail) =>
            init ::: v.reduce(scope).asInstanceOf[Parameter] :: tail
          case _ => ???
        }
        this.copy(parameters = reducedExpressions)
      case _ =>
        logger.warn("No parameter is reducible in " + this.toString)
        throw new IllegalArgumentException("No reducible parameter")
    }

  override def nextReducible: Scope => Option[Expression] = scope =>
    this.parameters.find(_.isReducible(scope)).flatMap(_.nextReducible(scope))

}
