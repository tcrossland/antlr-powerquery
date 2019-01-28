package io.truedat.functions

import io.truedat.ast.{ Expression, ListLiteral, TextLiteral, Transformation }

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

  def renameColumns: List[Expression] => Expression = {
    case table :: (renames : ListLiteral) :: _ =>
      val args = listLiteralToMap(renames)
      Transformation("RenameColumns", table, args)
    case _ =>
      throw new IllegalArgumentException("Expected 2 or 3 arguments")
  }

  def selectColumns: List[Expression] => Expression = {
    case table :: (columns : ListLiteral) :: _ =>
      val args = columns.value
      Transformation("RenameColumns", table, args)
    case _ =>
      throw new IllegalArgumentException("Expected 2 or 3 arguments")
  }

  def selectRows: List[Expression] => Expression = {
    case table :: condition :: Nil =>
      Transformation("SelectRows", table, condition)
    case _ =>
      throw new IllegalArgumentException("Expected 2 arguments")
  }

  def removeColumns: List[Expression] => Expression = {
    case table :: columns :: _ =>
      Transformation("RemoveColumns", table, columns)
    case _ =>
      throw new IllegalArgumentException("Expected 2 or 3 arguments")
  }

}
