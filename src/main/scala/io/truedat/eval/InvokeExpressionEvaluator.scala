package io.truedat.eval

import io.truedat.ast._
import io.truedat.functions._

trait InvokeExpressionEvaluator extends Evaluable {
  this: InvokeExpression =>

  override def isEvaluable: Scope => Boolean = scope =>
    isFunctionIdentified &&
      this.argumentList.expressions.forall(_.isReduced) &&
      isFunctionEvaluable(scope)

  def isFunctionIdentified: Boolean =
    this.expression.isInstanceOf[IdentifierExpression] ||
      this.expression.isInstanceOf[FunctionExpression]

  def isFunctionEvaluable: Scope => Boolean = scope =>
    this.expression match {
      case _: FunctionExpression => true
      case i: IdentifierExpression =>
        scope.closestBinding(i.identifier) match {
          case Some(e: LetExpression) =>
            e.isReduced
          case None =>
            i.identifier.id match {
              case fn if Functions.functions.contains(fn) => true
              case _ => false
            }
          case _ => false
        }
      case _ => false
    }

  override def evaluate: Scope => Expression = scope =>
    this.expression match {
      case i: IdentifierExpression =>
        scope.closestBinding(i.identifier) match {
          case Some(e: LetExpression) =>
            e
          case None =>
            i.identifier.id match {
              case fn if Functions.functions.contains(fn) =>
                Functions.functions(fn).apply(argumentList.expressions)
              case id =>
                throw new IllegalArgumentException("Unhandled id: " + id)
            }
          case _ =>
            ???
        }
      case f: FunctionExpression =>
        // bind arguments to function parameters
        val functionScope = Scope.extend(scope, f.parameterList, argumentList)
        f.evaluate(functionScope)
      case e =>
        throw new IllegalArgumentException("Unhandled function: " + e.toString)
    }
}
