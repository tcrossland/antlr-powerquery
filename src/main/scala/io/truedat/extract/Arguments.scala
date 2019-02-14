package io.truedat.extract

import io.truedat.ast._

object Arguments {
  def listLiteralToMap: List[Value] => Map[String, String] = {
    case list@(_: ListLiteral) :: _ =>
      list
        .map(_.asInstanceOf[ListLiteral])
        .map(listLiteralToPair)
        .toMap[String, String]
    case _ =>
      ???
  }

  def listLiteralToPair: ListLiteral => (String, String) = listLiteral =>
    (listLiteral.value.head.toString, listLiteral.value(1).toString)

  def listLiteralToList: ListLiteral => List[String] = lit => lit.value.map(_.toString)

  def itemListToList: ItemList => List[String] = itemList => itemList.list
    .map(_.asInstanceOf[ItemList])
    .map(itemListToString)

  def itemToString: Expression => String = {
    case b: Builtin => b.toString
    case TextLiteral(s) => s
    case NullableType(t) => "nullable " + itemToString(t)
    case TableType(_) => "table"
    case t: Type => t.toString
    case x =>
      val y = x
      ???
  }

  def itemListToPair: List[Expression] => (String, String) = {
    case h :: t :: Nil =>
      (itemToString(h), itemToString(t))
    case _ =>
      ???
  }

  def itemListToMap: List[Expression] => Map[String, String] = outerList =>
    outerList
      .map(_.asInstanceOf[ItemList])
      .map(_.list)
      .map(itemListToPair)
      .toMap[String, String]

  def itemListToString: ItemList => String = itemList => itemList.list.head.toString

  def recordLiteralToSet: RecordLiteral => Set[String] = rl => rl.value.map(_.name.id).toSet
}
