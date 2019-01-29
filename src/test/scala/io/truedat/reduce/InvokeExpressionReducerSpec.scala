package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class InvokeExpressionReducerSpec extends FlatSpec {
  case class FixtureParam(expression: InvokeExpression, scope: Scope)

  private def invokeExpressionWithFunctionExpression = new {
    val functionReturn = DataSource("Baz", None)
    val expression = InvokeExpression(
      FunctionExpression(
        ParameterList(
          Some(
            FixedParameterList(
              List(
                Parameter(Identifier("p1"),Some(BinaryType))
              )
            )
          ),
          None
        ),
        None,
        functionReturn
      ),
      ArgumentList(
        List(
          RequiredFieldSelector(Identifier("Field"))
        )
      )
    )
    val scope = new Scope(None, Map.empty)
  }

  "An InvokeExpression whose primary expression is FunctionExpression" should "be reducible" in {
    val f = invokeExpressionWithFunctionExpression
    assert(f.expression.isReducible(f.scope))
  }

  it should "reduce" in {
    val f = invokeExpressionWithFunctionExpression
    val e = f.expression.reduce(f.scope)
    assert(e == f.functionReturn)
  }
}