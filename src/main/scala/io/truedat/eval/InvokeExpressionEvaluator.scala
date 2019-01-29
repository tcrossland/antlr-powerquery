package io.truedat.eval

import io.truedat.ast._
import io.truedat.functions._

trait InvokeExpressionEvaluator extends Evaluable {
  this: InvokeExpression =>

  override def isEvaluable: Scope => Boolean = _ =>
    isFunctionIdentified(this.expression) &&
      this.argumentList.expressions.forall(_.isReduced)

  def isFunctionIdentified: Expression => Boolean = expression =>
    expression.isInstanceOf[IdentifierExpression] ||
      expression.isInstanceOf[IntrinsicFunction]

  override def evaluate: Scope => Expression = scope =>
    this.expression match {
      case i: IntrinsicFunction =>
        i match {
          case IntrinsicTableFunction =>
            TableFunctions.tableBuiltin(argumentList.expressions)
          case _ =>
            throw new IllegalArgumentException("Unhandled id: " + i.toString)
        }
      case i: IdentifierExpression =>
        scope.closestBinding(i.identifier) match {
          case Some(e: LetExpression) =>
            Function(i.identifier.id)
          case None =>
            i.identifier.id match {
              case "Date.Year" =>
                DateFunctions.year(argumentList.expressions)
              case "DateTime.LocalNow" =>
                DateTimeFunctions.localNow(argumentList.expressions)
              case "List.Max" =>
                ListFunctions.max(argumentList.expressions)
              case "Sql.Database" =>
                DataAccessFunctions.dataSource(
                  "Sql.Database",
                  this.argumentList.expressions
                )
              case "DataLake.Contents" =>
                  DataAccessFunctions.dataSource("DataLake.Contents", this.argumentList.expressions)
              case "Table.ColumnNames" =>
                TableFunctions.columnNames(argumentList.expressions)
              case "Table.FromRecords" =>
                TableFunctions.fromRecords(argumentList.expressions)
              case "Table.RemoveColumns" =>
                TableFunctions.removeColumns(argumentList.expressions)
              case "Table.RenameColumns" =>
                TableFunctions.renameColumns(argumentList.expressions)
              case "Table.SelectColumns" =>
                TableFunctions.selectColumns(argumentList.expressions)
              case "Table.SelectRows" =>
                TableFunctions.selectRows(argumentList.expressions)
              case "Table.TransformColumnTypes" =>
                TableFunctions.transformColumnTypes(argumentList.expressions)
              case "Table.AddColumn" =>
                TableFunctions.addColumn(argumentList.expressions)
              case "Table.ExpandTableColumn" =>
                TableFunctions.expandTableColumn(argumentList.expressions)
              case "Table.DuplicateColumn" =>
                TableFunctions.combine(argumentList.expressions) // TODO
              case "Table.Combine" =>
                TableFunctions.combine(argumentList.expressions)
              case "Table.Group" =>
                TableFunctions.combine(argumentList.expressions) // TODO
              case id =>
                throw new IllegalArgumentException("Unhandled id: " + id)
            }
        }
      case e =>
        throw new IllegalArgumentException("Unhandled function: " + e.toString)
    }
}
