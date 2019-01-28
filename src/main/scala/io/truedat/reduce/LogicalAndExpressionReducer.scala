package io.truedat.reduce

import io.truedat.ast.LogicalAndExpression
import io.truedat.eval.Scope

trait LogicalAndExpressionReducer extends Reducible {
  this: LogicalAndExpression =>

  override def isReducible: Scope => Boolean = scope => e1.isReducible(scope) || e2.isReducible(scope)
}
