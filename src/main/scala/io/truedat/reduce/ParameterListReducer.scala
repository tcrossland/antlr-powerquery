package io.truedat.reduce

import io.truedat.ast.{ Expression, FixedParameterList, OptionalParameterList, ParameterList }
import io.truedat.eval.Scope

trait ParameterListReducer extends Reducible {
  this: ParameterList =>

  override def isReducible: Scope => Boolean = scope =>
    this.fixedParameters.exists(_.isReducible(scope)) ||
      this.optionalParameters.exists(_.isReducible(scope))

  override def isReduced: Boolean =
    this.optionalParameters.forall(_.isReduced) &&
      this.fixedParameters.forall(_.isReduced)

  override def reduce: Scope => Expression = scope =>
    if (this.optionalParameters.exists(_.isReducible(scope)))
      this.copy(optionalParameters = optionalParameters.map(_.reduce(scope).asInstanceOf[OptionalParameterList]))
    else if (this.fixedParameters.exists(_.isReducible(scope)))
      this.copy(fixedParameters = fixedParameters.map(_.reduce(scope).asInstanceOf[FixedParameterList]))
    else
      ???
}
