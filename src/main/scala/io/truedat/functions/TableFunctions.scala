package io.truedat.functions

import io.truedat.ast._

object TableFunctions extends Functions {

  val functions: Map[String, List[Expression] => Expression] = List(
    "Table.AddColumn",
    "Table.ColumnNames",
    "Table.Combine",
    "Table.DuplicateColumn",
    "Table.ExpandTableColumn",
    "Table.FromRecords",
    "Table.FromRows",
    "Table.Group",
    "Table.NestedJoin",
    "Table.PromoteHeaders",
    "Table.RemoveColumns",
    "Table.RenameColumns",
    "Table.ReplaceValue",
    "Table.SelectColumns",
    "Table.SelectRows",
    "Table.Sort",
    "Table.TransformColumnTypes",
    "#table"
  ).map(s => (s, transformation(s))).toMap
}
