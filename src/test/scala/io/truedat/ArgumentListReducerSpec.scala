package io.truedat

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class ArgumentListReducerSpec extends FlatSpec {
  val argumentList = ArgumentList(
    List(
      DataSource("Foo", None),
      ItemList(
        List(
          ItemList(List(TextLiteral("FromDate"), IdentifierExpression(Identifier("Int64.Type")))),
          ItemList(List(TextLiteral("ToDate"), IdentifierExpression(Identifier("Int64.Type")))),
          ItemList(List(TextLiteral("Users"), IdentifierExpression(Identifier("Int64.Type")))),
          ItemList(List(TextLiteral("newUsers"), IdentifierExpression(Identifier("Int64.Type")))),
          ItemList(List(TextLiteral("Sessions"), IdentifierExpression(Identifier("Int64.Type")))),
          ItemList(List(TextLiteral("avgSessionDuration"), NumberType))
        )
      ),
      TextLiteral("en-US")
    )
  )
  val scope: Scope = new Scope(None, Map.empty)

  "An argument list" should "be reducible if it's variables are reducible" in {
    assert(argumentList.isReducible(scope) || argumentList.isReduced)
  }

}
