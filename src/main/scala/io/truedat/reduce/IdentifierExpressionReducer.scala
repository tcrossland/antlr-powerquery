package io.truedat.reduce

import io.truedat.ast.{ Expression, IdentifierExpression }
import io.truedat.eval.Scope

trait IdentifierExpressionReducer extends Reducible {
  this: IdentifierExpression =>

  override def isReducible: Scope => Boolean = scope => {
    val binding = scope.closestBinding(identifier)
    binding.isDefined && binding.get.isReduced
  }

  override def reduce: Scope => Expression = scope =>
    scope.closestBinding(identifier).get
}
