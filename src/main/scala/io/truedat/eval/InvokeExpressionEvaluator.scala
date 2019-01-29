package io.truedat.eval

import io.truedat.ast._
import io.truedat.functions._

trait InvokeExpressionEvaluator extends Evaluable {
  this: InvokeExpression =>

  override def isEvaluable: Scope => Boolean = _ =>
    isFunctionIdentified(this.expression) &&
      this.argumentList.expressions.forall(_.isReduced)

  def isFunctionIdentified: Expression => Boolean = expression =>
    expression.isInstanceOf[IdentifierExpression] ||
      expression.isInstanceOf[FunctionExpression]

  override def evaluate: Scope => Expression = scope =>
    this.expression match {
      case i: IdentifierExpression =>
        scope.closestBinding(i.identifier) match {
          case Some(_: LetExpression) =>
            Function(i.identifier.id)
          case None =>
            i.identifier.id match {
              case fn if TableFunctions.functions.contains(fn) =>
                TableFunctions.functions(fn).apply(argumentList.expressions)
              case fn if DateTimeFunctions.functions.contains(fn) =>
                DateTimeFunctions.functions(fn).apply(argumentList.expressions)
              case fn if DataAccessFunctions.functions.contains(fn) =>
                DataAccessFunctions.functions(fn).apply(argumentList.expressions)
              case fn if ListFunctions.functions.contains(fn) =>
                ListFunctions.functions(fn).apply(argumentList.expressions)
              case fn if BinaryFunctions.functions.contains(fn) =>
                BinaryFunctions.functions(fn).apply(argumentList.expressions)
              case id =>
                throw new IllegalArgumentException("Unhandled id: " + id)
            }
        }
      case f: FunctionExpression =>
        // bind arguments to function parameters
        val functionScope = Scope.extend(scope, f.parameterList, argumentList)
        f.evaluate(functionScope)
      case e =>
        throw new IllegalArgumentException("Unhandled function: " + e.toString)
    }
}
