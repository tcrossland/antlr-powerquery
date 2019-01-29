package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class FunctionExpressionReducerSpec extends FlatSpec {
  val fixedParameter = Parameter(Identifier("P1"), Some(BinaryType))
  val fixedParameterList = FixedParameterList(List(fixedParameter))
  val parameterList = ParameterList(Some(fixedParameterList), None)
  val functionExpression = FunctionExpression(parameterList, None, DataSource("Foo", None))
  val scope: Scope = new Scope(None, Map.empty)

  "A function expression" should "be reduced if it's parameter list and body are reduced" in {
    assert(functionExpression.isReducible(scope) || functionExpression.isReduced)
  }

}
