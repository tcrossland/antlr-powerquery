package io.truedat.reduce

import io.truedat.ast.{ Expression, Variable, VariableList }
import io.truedat.eval.Scope

trait VariableListReducer extends Reducible {
  this: VariableList =>

  override def isReduced: Boolean = this.variables.forall(_.isReduced)

  override def isReducible: Scope => Boolean = scope =>
    this.variables.exists(_.isReducible(scope))

  override def reduce: Scope => Expression = scope => {
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

}
