package io.truedat.eval

object Scope {
  var id: Int = 0
  def nextId: Int = { val i = id; id += 1; i }
  val TOP = new Scope(None, Set())
}

class Scope(val parent: Option[Scope], val boundNames: Set[String]) {
  val id: Int = Scope.nextId

  def closestBinding(name: String): Option[Scope] =
    if (boundNames contains name)
      Some(this)
    else
      parent flatMap (_ closestBinding name)
}