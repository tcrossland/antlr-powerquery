package io.truedat.eval

import io.truedat.ast._

trait RecordExpressionEvaluator extends Evaluable {
  this: RecordExpression =>

  override def isEvaluable: Scope => Boolean = _ =>
    this.fieldList.fields.forall(_.isReduced)

  override def evaluate: Scope => Expression = _ =>
    RecordLiteral(this.fieldList.fields.map(fieldToLiteral))

  def fieldToLiteral: Field => LiteralField = f =>
    LiteralField(f.fieldName, f.expression.asInstanceOf[Value])

}
