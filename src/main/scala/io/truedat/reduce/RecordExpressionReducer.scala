package io.truedat.reduce

import io.truedat.ast.{ Expression, FieldList, RecordExpression }
import io.truedat.eval.Scope

trait RecordExpressionReducer extends Reducible {
  this: RecordExpression =>

  override def isReducible: Scope => Boolean = scope =>
    this.fieldList.isReducible(scope) || this.isEvaluable(scope)

  override def isReduced: Boolean =
    this.fieldList.isReduced

  override def reduce: Scope => Expression = scope =>
    if (this.fieldList.isReducible(scope))
      this.copy(fieldList = this.fieldList.reduce(scope).asInstanceOf[FieldList])
    else if (this.isEvaluable(scope))
      this.evaluate(scope)
    else
      ???
}
