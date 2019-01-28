package io.truedat.ast

import io.truedat.eval.Scope

trait Reducible {
  def isReducible: Scope => Boolean = _ => false

  def reduce: Scope => Expression = _ => ???

  def isReduced: Boolean = false
}

trait ExpressionReducer extends Reducible {
  this: Expression =>
}

trait LogicalOrExpressionReducer extends Reducible {
  this: LogicalOrExpression =>
  override def isReducible: Scope => Boolean = scope => e1.isReducible(scope) || e2.isReducible(scope)
}

trait LogicalAndExpressionReducer extends Reducible {
  this: LogicalAndExpression =>
  override def isReducible: Scope => Boolean = scope => e1.isReducible(scope) || e2.isReducible(scope)
}

trait LetExpressionReducer extends Reducible {
  this: LetExpression =>

  def getScope: Scope => Scope = parentScope => Scope.extend(parentScope, this)

  override def isReducible: Scope => Boolean = parentScope => {
    val scope = getScope(parentScope)
    this.variableList.isReducible(scope) ||
      this.variableList.isReduced && this.expression.isReducible(scope)
  }

  override def reduce: Scope => Expression = parentScope => {
    val scope = getScope(parentScope)
    if (this.variableList.isReducible(scope))
      this.copy(variableList = this.variableList.reduce(scope).asInstanceOf[VariableList])
    else if (this.variableList.isReduced && this.expression.isReducible(scope))
      this.expression.reduce(scope)
    else
      ???
  }
}

trait VariableListReducer extends Reducible {
  this: VariableList =>

  override def isReduced: Boolean = this.variables.forall(_.isReduced)

  override def isReducible: Scope => Boolean = scope =>
    this.variables.exists(_.isReducible(scope))

  override def reduce: Scope => Expression = scope => {
    val i = this.variables.indexWhere(_.isReducible(scope))
    val reducedVariables = this.variables.splitAt(i) match {
      case (init, v :: tail) =>
        init ::: v.reduce(scope).asInstanceOf[Variable] :: tail
      case _ => ???
    }
    this.copy(variables = reducedVariables)
  }

}

trait VariableReducer extends Reducible {
  this: Variable =>

  override def isReduced: Boolean = this.expression.isReduced

  override def isReducible: Scope => Boolean = scope => this.expression.isReducible(scope)

  override def reduce: Scope => Expression = scope =>
    this.copy(
      expression = this.expression.reduce(scope)
    )
}

trait InvokeExpressionReducer extends Reducible {
  this: InvokeExpression =>

  override def isReducible: Scope => Boolean = scope =>
    this.expression.isReducible(scope) ||
      this.argumentList.isReducible(scope) ||
      this.isEvaluable(scope)

  def isEvaluable: Scope => Boolean = scope =>
    this.expression.isInstanceOf[IdentifierExpression] &&
      this.argumentList.expressions.forall(_.isReduced)

  override def reduce: Scope => Expression = scope =>
    if (this.expression.isReducible(scope)) {
      this.copy(expression = this.expression.reduce(scope))
    } else if (this.argumentList.isReducible(scope)) {
      this.copy(argumentList = this.argumentList.reduce(scope).asInstanceOf[ArgumentList])
    } else if (this.isEvaluable(scope)) {
      DataSource(
        this.expression.asInstanceOf[IdentifierExpression].identifier.id,
        this.argumentList.expressions.map(_.asInstanceOf[Value])
      )
    } else
      ???
}

trait ArgumentListReducer extends Reducible {
  this: ArgumentList =>

  override def isReducible: Scope => Boolean = scope =>
    this.expressions.exists(_.isReducible(scope))

  override def reduce: Scope => Expression = scope =>
    this.copy(expressions = this.expressions.map(e =>
      if (e.isReducible(scope)) e.reduce(scope) else e
    ))
}

trait IdentifierExpressionReducer extends Reducible {
  this: IdentifierExpression =>

  override def isReducible: Scope => Boolean = scope => {
    val binding = scope.closestBinding(identifier)
    binding.isDefined && binding.get.isReduced
  }

  override def reduce: Scope => Expression = scope =>
    scope.closestBinding(identifier).get
}

trait ItemSelectionReducer extends Reducible {
  this: ItemSelection =>

  override def isReducible: Scope => Boolean = scope =>
    this.expression.isReducible(scope) ||
      this.itemSelector.isReducible(scope)

  override def reduce: Scope => Expression = scope =>
    if (this.expression.isReducible(scope))
      this.copy(expression = this.expression.reduce(scope))
    else if (this.itemSelector.isReducible(scope))
      this.copy(itemSelector = this.itemSelector.reduce(scope))
    else
      ???
}

trait FieldSelectionReducer extends Reducible {
  this: FieldSelection =>

  override def isReducible: Scope => Boolean = scope =>
    this.expression.isReducible(scope) ||
      this.selection.isReducible(scope)

  override def reduce: Scope => Expression = scope =>
    if (this.expression.isReducible(scope))
      this.copy(expression = this.expression.reduce(scope))
    else if (this.selection.isReducible(scope))
      this.copy(selection = this.selection.reduce(scope).asInstanceOf[FieldSelector])
    else
      ???
}

trait ValueReducer extends Reducible {
  this: Value =>
  override def isReducible: Scope => Boolean = _ => false

  override def isReduced: Boolean = true
}