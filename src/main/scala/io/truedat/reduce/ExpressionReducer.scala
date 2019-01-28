package io.truedat.reduce

import io.truedat.ast.Expression

trait ExpressionReducer extends Reducible {
  this: Expression =>
}
