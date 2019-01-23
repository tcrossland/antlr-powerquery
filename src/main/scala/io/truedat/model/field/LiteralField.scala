package io.truedat.model.field

import io.truedat.model.Node
import io.truedat.model.identifier.Identifier
import io.truedat.model.literal.Literal

case class LiteralField(name: Identifier, value: Literal) extends Node

