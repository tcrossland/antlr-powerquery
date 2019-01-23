package io.truedat.model.item

import io.truedat.model.Node

case class ItemList(list: List[Item]) extends Node {
  def value: Any = list
}
