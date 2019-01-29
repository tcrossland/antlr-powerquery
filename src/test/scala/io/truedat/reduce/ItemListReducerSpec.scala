package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class ItemListReducerSpec extends FlatSpec {
  val itemList = ItemList(List(TextLiteral("FromDate"), IdentifierExpression(Identifier("Int64.Type"))))
  val scope: Scope = new Scope(None, Map.empty)

  "An item list" should "be reducible if it's items are reducible" in {
    assert(itemList.isReducible(scope) || itemList.isReduced)
  }

}
