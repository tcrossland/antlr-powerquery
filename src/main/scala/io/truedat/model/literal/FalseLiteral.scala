package io.truedat.model.literal

case object FalseLiteral extends LogicalLiteral {
  override def value: Boolean = false
}
