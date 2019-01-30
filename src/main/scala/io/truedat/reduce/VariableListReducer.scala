package io.truedat.reduce

import io.truedat.ast.{ Expression, Variable, VariableList }
import io.truedat.eval.Scope

trait VariableListReducer extends Reducible {
  this: VariableList =>

  def getScope: Scope => Scope = parentScope => Scope.extend(parentScope, this)

  override def isReduced: Boolean = this.variables.forall(_.isReduced)

  override def isReducible: Scope => Boolean = parentScope => {
    val scope = getScope(parentScope)
    this.variables.exists(_.isReducible(scope))
  }

  override def reduce: Scope => Expression = parentScope => {
    val scope = getScope(parentScope)
    this.variables.indexWhere(_.isReducible(scope)) match {
      case i if i > -1 =>
        val reducedVariables = this.variables.splitAt(i) match {
          case (init, v :: tail) =>
            init ::: v.reduce(scope).asInstanceOf[Variable] :: tail
          case _ => ???
        }
        this.copy(variables = reducedVariables)
      case _ => ???
    }
  }

  override def nextReducible: Scope => Option[Expression] = parentScope => {
    val scope = getScope(parentScope)
    this.variables.find(_.isReducible(scope)).flatMap(_.nextReducible(scope))
  }

}
