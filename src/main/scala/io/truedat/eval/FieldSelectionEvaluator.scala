package io.truedat.eval

import io.truedat.ast._

trait FieldSelectionEvaluator extends Evaluable {
  this: FieldSelection =>

  override def isEvaluable: Scope => Boolean = _ =>
    this.selection match {
      case r: RequiredFieldSelector =>
        r.name.id == "Data"
      case o: OptionalFieldSelector =>
        o.name.id == "Data"
      case _ =>
        ???
    }

  override def evaluate: Scope => Expression = _ =>
    this.expression
}
