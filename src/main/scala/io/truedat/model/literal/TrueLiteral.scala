package io.truedat.model.literal

case object TrueLiteral extends LogicalLiteral {
  override def value: Boolean = true
}
