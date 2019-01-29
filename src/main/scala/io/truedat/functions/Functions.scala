package io.truedat.functions

import io.truedat.ast._

trait Functions {
  def transformation: String => List[Expression] => Expression = fn => {
    case head :: tail =>
      Transformation(fn, head, tail)
    case Nil =>
      Builtin(fn)
    case _ =>
      throw new IllegalArgumentException("Expected arguments")
  }

  def listLiteralToPair: ListLiteral => (String, String) = listLiteral =>
    (listLiteral.value.head.toString, listLiteral.value(1).toString)

  def listLiteralToMap: ListLiteral => Map[String, String] = listLiteral =>
    listLiteral.value match {
      case (_: ListLiteral) :: _ =>
        listLiteral.value
          .map(_.asInstanceOf[ListLiteral])
          .map(listLiteralToPair)
          .toMap[String, String]
      case (_: TextLiteral) :: (_: TextLiteral) :: Nil =>
        Map[String, String](listLiteralToPair(listLiteral))
      case _ =>
        ???
    }


}
