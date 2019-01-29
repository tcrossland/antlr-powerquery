package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope

trait EachExpressionReducer extends Reducible {
  this: EachExpression =>

  override def isReducible: Scope => Boolean = _ => true

  override def reduce: Scope => Expression = scope => {
    val implicitTargets = FixedParameterList(List(Parameter(Identifier("_"), None)))
    val parameterList = ParameterList(Some(implicitTargets), None)
    FunctionExpression(parameterList, None, this.functionBody)
    // this.functionBody
  }
}
