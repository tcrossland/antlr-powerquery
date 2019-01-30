package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class ItemListReducerSpec extends FlatSpec {
  private def itemListFixture = new {
    val itemList = ItemList(List(TextLiteral("FromDate"), IdentifierExpression(Identifier("Int64.Type"))))
  }

  private def nestedItemListFixture = new {
    val itemList = ItemList(
      List(
        ItemList(List(TextLiteral("FromDate"), IdentifierExpression(Identifier("Int64.Type")))),
        ItemList(List(TextLiteral("ToDate"), IdentifierExpression(Identifier("Int64.Type")))),
        ItemList(List(TextLiteral("avgDuration"), NumberType))
      )
    )
  }

  "An ItemList" should "be reducible if any of its items are reducible" in {
    val f = itemListFixture
    assert(f.itemList.isReducible(Scope.empty()))
  }

  "A nested ItemList" should "be reducible if any of its items are reducible" in {
    val f = nestedItemListFixture
    assert(f.itemList.isReducible(Scope.empty()))
  }

  it should "identify a reducible expression within a nested ItemList" in {
    val f = nestedItemListFixture

    val n = f.itemList.nextReducible(Scope.empty())

    assert(n.isDefined)
    assert(n.get == IdentifierExpression(Identifier("Int64.Type")))
  }

}
