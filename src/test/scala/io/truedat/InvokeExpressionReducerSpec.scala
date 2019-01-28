package io.truedat

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class InvokeExpressionReducerSpec extends FlatSpec {
  val identifier = Identifier("Sql.Database")
  val bindings: Map[Identifier, Expression] = Map(
    Identifier("server") -> TextLiteral("some.database.windows.net")
  )
  val scope = new Scope(None, bindings)
  val argumentList = ArgumentList(
    List(
      IdentifierExpression(Identifier("server"))
    )
  )
  val invokeExpression = InvokeExpression(IdentifierExpression(identifier), argumentList)

  "A function invocation expression" should "be reducible if any of it's arguments are reducible" in {
    assert(invokeExpression.isReducible(scope))
  }

  it should "reduce correctly" in {
    val e1 = invokeExpression.reduce(scope)
    assert(e1 == InvokeExpression(
      IdentifierExpression(Identifier("Sql.Database")),
      ArgumentList(List(TextLiteral("some.database.windows.net"))))
    )
    assert(e1.isReducible(scope))
    val e2 = e1.reduce(scope)
    assert(e2 == DataSource("Sql.Database",List(TextLiteral("some.database.windows.net"))))
  }
}