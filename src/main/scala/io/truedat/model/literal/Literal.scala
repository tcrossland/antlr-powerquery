package io.truedat.model.literal

import io.truedat.model.Node

trait Literal extends Node {
  def value: Any
}
