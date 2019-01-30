package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class IdentifierExpressionReducerSpec extends FlatSpec {
  import scala.language.reflectiveCalls

  private def fixture = new {
    val expression = IdentifierExpression(Identifier("Int64.Type"))
  }

  "An IdentifierExpression" should "be reducible if any of its items are reducible" in {
    val f = fixture
    assert(f.expression.isReducible(Scope.empty()))
  }

  it should "identify a reducible expression within a nested ItemList" in {
    val f = fixture
    val reducible = f.expression.nextReducible(Scope.empty())

    assert(reducible.isDefined)
    assert(reducible.get == f.expression)
  }

  it should "reduce the Int64.Type expression to a NumberType" in {
    val f = fixture
    val reduced = f.expression.reduce(Scope.empty())
    assert(reduced == NumberType)
  }

}
