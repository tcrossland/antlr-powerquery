package io.truedat.eval

import io.truedat.ast._
import io.truedat.functions.{ ListFunctions, DataAccessFunctions, TableFunctions }

trait InvokeExpressionEvaluator extends Evaluable {
  this: InvokeExpression =>

  override def isEvaluable: Scope => Boolean = _ =>
    this.expression.isInstanceOf[IdentifierExpression] &&
      this.argumentList.expressions.forall(e => e.isReduced)

  override def evaluate: Scope => Expression = _ =>
    this.expression.asInstanceOf[IdentifierExpression].identifier.id match {
      case "List.Max" =>
        ListFunctions.max(argumentList.expressions)
      case "Sql.Database" =>
        DataAccessFunctions.dataSource(
          "Sql.Database",
          this.argumentList.expressions
        )
      case "Table.RemoveColumns" =>
        TableFunctions.removeColumns(argumentList.expressions)
      case "Table.RenameColumns" =>
        TableFunctions.renameColumns(argumentList.expressions)
      case "Table.SelectColumns" =>
        TableFunctions.selectColumns(argumentList.expressions)
      case "Table.SelectRows" =>
        TableFunctions.selectRows(argumentList.expressions)
      case id =>
        throw new IllegalArgumentException("Unhandled id: " + id)
    }
}
