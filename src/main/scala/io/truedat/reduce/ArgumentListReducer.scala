package io.truedat.reduce

import io.truedat.ast.{ ArgumentList, Expression }
import io.truedat.eval.Scope

trait ArgumentListReducer extends Reducible {
  this: ArgumentList =>

  override def isReducible: Scope => Boolean = scope =>
    this.expressions.exists(_.isReducible(scope))

  override def reduce: Scope => Expression = scope =>
    this.copy(expressions = this.expressions.map(e =>
      if (e.isReducible(scope)) e.reduce(scope) else e
    ))
}
