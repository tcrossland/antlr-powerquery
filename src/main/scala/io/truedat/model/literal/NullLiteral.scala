package io.truedat.model.literal

case object NullLiteral extends Literal {
  override def value: Null = null
}
