package io.truedat.reduce

import io.truedat.ast.LogicalOrExpression
import io.truedat.eval.Scope

trait LogicalOrExpressionReducer extends Reducible {
  this: LogicalOrExpression =>
  override def isReducible: Scope => Boolean = scope => e1.isReducible(scope) || e2.isReducible(scope)
}
