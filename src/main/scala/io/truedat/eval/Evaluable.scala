package io.truedat.eval

import io.truedat.ast.Expression
import io.truedat.reduce.Reducible

trait Evaluable {
  this: Reducible =>

  def isEvaluable: Scope => Boolean = _ => false

  def evaluate: Scope => Expression = _ => ???
}
