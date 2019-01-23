package io.truedat.model.item

import io.truedat.model.Node
import io.truedat.model.expression.Expression

case class Sequence(from: Expression, to: Expression) extends Node {
  def value: Any = (from, to)
}
