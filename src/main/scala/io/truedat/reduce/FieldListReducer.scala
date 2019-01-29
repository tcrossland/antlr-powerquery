package io.truedat.reduce

import io.truedat.ast.{ Expression, Field, FieldList }
import io.truedat.eval.Scope

trait FieldListReducer extends Reducible {
  this: FieldList =>

  override def isReducible: Scope => Boolean = scope =>
    this.fields.exists(_.isReducible(scope))

  override def isReduced: Boolean =
    this.fields.forall(_.isReduced)

  override def reduce: Scope => Expression = scope =>
    this.fields.indexWhere(_.isReducible(scope)) match {
      case i if i > -1 =>
        val reducedFields = this.fields.splitAt(i) match {
          case (init, f :: tail) =>
            init ::: f.reduce(scope).asInstanceOf[Field] :: tail
          case _ => ???
        }
        this.copy(fields = reducedFields)
      case _ =>
        ???
    }

  override def nextReducible: Scope => Option[Expression] = scope =>
    this.fields.find(_.isReducible(scope)).flatMap(_.nextReducible(scope))

}
