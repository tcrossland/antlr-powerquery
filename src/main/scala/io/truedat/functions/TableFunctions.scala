package io.truedat.functions

import io.truedat.ast._

object TableFunctions {

  def listLiteralToPair: ListLiteral => (String, String) = listLiteral =>
    (listLiteral.value.head.toString, listLiteral.value(1).toString)

  def listLiteralToMap: ListLiteral => Map[String, String] = listLiteral =>
    listLiteral.value match {
      case (_: ListLiteral) :: _ =>
        listLiteral.value
          .map(_.asInstanceOf[ListLiteral])
          .map(listLiteralToPair)
          .toMap[String, String]
      case (_ : TextLiteral) :: (_ : TextLiteral) :: Nil =>
        Map[String, String](listLiteralToPair(listLiteral))
      case _ =>
        ???
    }

  def columnNames: List[Expression] => Expression = {
    case table :: Nil =>
      Transformation("Table.ColumnNames", table, None)
    case _ =>
      throw new IllegalArgumentException("Expected 1 argument")
  }

  def fromRecords: List[Expression] => Expression = {
    case records :: columns :: _ =>
      Transformation("Table.FromRecords", records, columns)
    case records :: Nil =>
      Transformation("Table.FromRecords", records, None)
    case _ =>
      throw new IllegalArgumentException("Expected 1-3 arguments")
  }

  def renameColumns: List[Expression] => Expression = {
    case table :: (renames : ListLiteral) :: _ =>
      val args = listLiteralToMap(renames)
      Transformation("Table.RenameColumns", table, args)
    case _ =>
      throw new IllegalArgumentException("Expected 2 or 3 arguments")
  }

  def selectColumns: List[Expression] => Expression = {
    case table :: (columns : ListLiteral) :: _ =>
      val args = columns.value
      Transformation("Table.SelectColumns", table, args)
    case _ =>
      throw new IllegalArgumentException("Expected 2 or 3 arguments")
  }

  def selectRows: List[Expression] => Expression = {
    case table :: condition :: Nil =>
      Transformation("Table.SelectRows", table, condition)
    case _ =>
      throw new IllegalArgumentException("Expected 2 arguments")
  }

  def removeColumns: List[Expression] => Expression = {
    case table :: columns :: _ =>
      Transformation("Table.RemoveColumns", table, columns)
    case _ =>
      throw new IllegalArgumentException("Expected 2 or 3 arguments")
  }

  def tableBuiltin: List[Expression] => Expression = {
    case columns :: (rows: ItemList) :: Nil =>
      Transformation("#table", rows, columns)
    case _ =>
      throw new IllegalArgumentException("Expected 2 arguments")
  }

  def transformColumnTypes: List[Expression] => Expression = {
    case table :: typeTransformations :: _ =>
      Transformation("Table.TransformColumnTypes", table, typeTransformations)
    case _ =>
      throw new IllegalArgumentException("Expected 2 or 3 arguments")
  }

  def expandTableColumn: List[Expression] => Expression = {
    case table :: column :: columnNames :: _ =>
      Transformation("Table.ExpandTableColumn", table, List(column, columnNames))
    case _ =>
      throw new IllegalArgumentException("Expected 3-4 arguments")
  }

  def addColumn: List[Expression] => Expression = {
    case table :: newColumnName :: columnGenerator :: _ =>
      Transformation("Table.AddColumn", table, List(newColumnName, columnGenerator))
    case _ =>
      throw new IllegalArgumentException("Expected 3-4 arguments")
  }

  def combine: List[Expression] => Expression = {
    case table :: rest =>
      Transformation("Table.Combine", table, rest)
    case _ =>
      throw new IllegalArgumentException("Expected XX arguments")
  }

}
