package io.truedat.eval

import io.truedat.ast._

trait DataSourceEvaluator {
  this: DataSource =>

  def getTextLiteralValue: RecordLiteral => String => String = r => fieldName =>
    r.value.find(_.name.id == fieldName).map(_.value.asInstanceOf[TextLiteral]).map(_.value).get

  def evaluate: Expression => Expression = {
    case r: RecordLiteral =>
      val schema = getTextLiteralValue(r)("Schema")
      val item = getTextLiteralValue(r)("Item")
      DataStructure(schema, item, this)
    case _ =>
      ???
  }
}
