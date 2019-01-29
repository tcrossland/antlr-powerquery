package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class ParameterListReducerSpec extends FlatSpec {
  val fixedParameter = Parameter(Identifier("P1"), Some(BinaryType))
  val fixedParameterList = FixedParameterList(List(fixedParameter))
  val parameterList = ParameterList(Some(fixedParameterList), None)
  val scope: Scope = new Scope(None, Map.empty)

  "A parameter list" should "be reduced if it's fixed parameters and optional parameters are reduced" in {
    assert(parameterList.isReducible(scope) || parameterList.isReduced)
  }

}
