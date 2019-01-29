package io.truedat.eval

import io.truedat.ast._

object Scope {
  def create(section: Section): Scope =
    Scope(None, section.members.map(m => (m.name, m.expression)).toMap)

  def extend(parent: Scope, e: Expression): Scope = e match {
    case v: VariableList =>
      Scope(
        Some(parent),
        v.variables.map(m => (m.name, m.expression)).toMap
      )
    case l: LetExpression =>
      extend(parent, l.variableList)
    case f: FunctionExpression =>
      extend(parent, f.parameterList)
    case p: ParameterList => {
      val params = p.fixedParameters.map(_.parameters).getOrElse(List.empty[Parameter]) ++
        p.optionalParameters.map(_.parameters).getOrElse(List.empty[Parameter])
      Scope(
        Some(parent),
        params.map(p => (p.identifier, p)).toMap
      )
    }
    case _ => ???
  }

  def extend(parent: Scope, parameterList: ParameterList, argumentList: ArgumentList): Scope = {
    val fixedParameters = parameterList.fixedParameters.map(_.parameters.map(_.identifier)).getOrElse(List.empty)
    val optionalParameters = parameterList.optionalParameters.map(_.parameters.map(_.identifier)).getOrElse(List.empty)
    val fixedArgs = argumentList.expressions.take(fixedParameters.size)
    val optionalArgs = argumentList.expressions.slice(fixedParameters.size, fixedParameters.size + optionalParameters.size)
    val bindings = fixedParameters.zip(fixedArgs) ++ optionalParameters.zip(optionalArgs)
    Scope(Some(parent), bindings.toMap)
  }
}

case class Scope(parent: Option[Scope], bindings: Map[Identifier, Expression]) {
  def closestBinding(name: Identifier): Option[Expression] =
    if (bindings.contains(name))
      Some(bindings(name))
    else
      parent.flatMap(_.closestBinding(name))
}