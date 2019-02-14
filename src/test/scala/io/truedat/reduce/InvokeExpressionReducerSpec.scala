package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope
import io.truedat.functions.`Sql.Database`
import org.scalatest.FlatSpec

class InvokeExpressionReducerSpec extends FlatSpec {

  import scala.language.reflectiveCalls

  case class FixtureParam(expression: InvokeExpression, scope: Scope)

  private def fixture = new {
    val fixedParameterList = FixedParameterList(List(Parameter(Identifier("p1"), Some(BinaryType))))
    val argumentList = ArgumentList(List(RequiredFieldSelector(Identifier("Field"))))
    val functionBody = ItemSelection(`Sql.Database`(List.empty), RecordLiteral(List.empty))
    val functionExpression = FunctionExpression(ParameterList(Some(fixedParameterList), None), None, functionBody)
    val invokeExpression = InvokeExpression(functionExpression, argumentList)
  }

  "An InvokeExpression whose primary expression is FunctionExpression" should "be reducible" in {
    val f = fixture
    assert(f.invokeExpression.isReducible(Scope.empty()))
  }

  it should "reduce to the functions body" in {
    val f = fixture
    val reduced = f.invokeExpression.reduce(Scope.empty())
    assert(reduced == f.functionBody)
  }
}