package io.truedat.reduce

import io.truedat.ast.Expression
import io.truedat.eval.Scope

trait ExpressionReducer extends Reducible {
  this: Expression =>

  override def nextReducible: Scope => Option[Expression] = scope =>
    if (this.isReducible(scope)) Some(this) else None

}
