package io.truedat.functions

import io.truedat.ast._

object TableFunctions {

  val functions: Map[String, List[Expression] => Expression] = Map(
    "Table.AddColumn" -> `Table.AddColumn`.apply,
    "Table.ColumnNames" -> `Table.ColumnNames`.apply,
    "Table.Combine" -> `Table.Combine`.apply,
    "Table.DuplicateColumn" -> `Table.DuplicateColumn`.apply,
    "Table.ExpandTableColumn" -> `Table.ExpandTableColumn`.apply,
    "Table.FromRecords" -> `Table.FromRecords`.apply,
    "Table.FromRows" -> `Table.FromRows`.apply,
    "Table.Group" -> `Table.Group`.apply,
    "Table.NestedJoin" -> `Table.NestedJoin`.apply,
    "Table.PromoteHeaders" -> `Table.PromoteHeaders`.apply,
    "Table.RemoveColumns" -> `Table.RemoveColumns`.apply,
    "Table.RenameColumns" -> `Table.RenameColumns`.apply,
    "Table.ReplaceValue" -> `Table.ReplaceValue`.apply,
    "Table.SelectColumns" -> `Table.SelectColumns`.apply,
    "Table.SelectRows" -> `Table.SelectRows`.apply,
    "Table.Sort" -> `Table.Sort`.apply,
    "Table.TransformColumnTypes" -> `Table.TransformColumnTypes`.apply,
    "#table" -> `#table`.apply
  )
}

case class `Table.AddColumn`(args: List[Expression]) extends LibraryFunction
case class `Table.ColumnNames`(args: List[Expression]) extends LibraryFunction
case class `Table.Combine`(args: List[Expression]) extends LibraryFunction
case class `Table.DuplicateColumn`(args: List[Expression]) extends LibraryFunction
case class `Table.ExpandTableColumn`(args: List[Expression]) extends LibraryFunction
case class `Table.FromRecords`(args: List[Expression]) extends LibraryFunction
case class `Table.FromRows`(args: List[Expression]) extends LibraryFunction
case class `Table.Group`(args: List[Expression]) extends LibraryFunction
case class `Table.NestedJoin`(args: List[Expression]) extends LibraryFunction
case class `Table.PromoteHeaders`(args: List[Expression]) extends LibraryFunction
case class `Table.RemoveColumns`(args: List[Expression]) extends LibraryFunction
case class `Table.RenameColumns`(args: List[Expression]) extends LibraryFunction
case class `Table.ReplaceValue`(args: List[Expression]) extends LibraryFunction
case class `Table.SelectColumns`(args: List[Expression]) extends LibraryFunction
case class `Table.SelectRows`(args: List[Expression]) extends LibraryFunction
case class `Table.Sort`(args: List[Expression]) extends LibraryFunction
case class `Table.TransformColumnTypes`(args: List[Expression]) extends LibraryFunction
case class `#table`(args: List[Expression]) extends LibraryFunction {
  override def functionName: String = "#table"
  override def toString: String = functionName + args.mkString("(", ",", ")")
}
