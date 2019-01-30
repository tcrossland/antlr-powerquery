package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class ArgumentListReducerSpec extends FlatSpec {

  private def nestedItemListFixture = new {
    val itemList = ItemList(
      List(
        ItemList(List(TextLiteral("FromDate"), IdentifierExpression(Identifier("Int64.Type")))),
        ItemList(List(TextLiteral("ToDate"), IdentifierExpression(Identifier("Int64.Type")))),
        ItemList(List(TextLiteral("avgDuration"), NumberType))
      )
    )
  }

  private def argumentListFixture = new {
    private val itemListFixture = nestedItemListFixture

    import itemListFixture._

    val argumentList = ArgumentList(
      List(
        DataSource("Foo", List.empty),
        itemList,
        TextLiteral("en-US")
      )
    )
  }

  "An ArgumentList" should "be reducible if any of its expressions are reducible" in {
    val f = argumentListFixture

    assert(f.argumentList.isReducible(Scope.empty()))
  }

  it should "identify a reducible expression within a nested ItemList" in {
    val f = argumentListFixture

    val n = f.argumentList.nextReducible(Scope.empty())

    assert(n.isDefined)
    assert(n.get == IdentifierExpression(Identifier("Int64.Type")))
  }

}
