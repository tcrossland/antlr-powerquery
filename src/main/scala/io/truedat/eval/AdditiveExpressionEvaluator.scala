package io.truedat.eval

import io.truedat.ast._

trait AdditiveExpressionEvaluator extends Evaluable {
  this: AdditiveExpression =>

  override def isEvaluable: Scope => Boolean = _ =>
    (op, e1, e2) match {
      case (Ampersand, TextLiteral(_), TextLiteral(_)) => true
      case (Ampersand, RequiredFieldSelector(Identifier(_)), TextLiteral(_)) => true
      case _ => false
    }

  override def evaluate: Scope => Expression = _ =>
    (op, e1, e2) match {
      case (Ampersand, TextLiteral(v1), TextLiteral(v2)) => TextLiteral(v1 + v2)
      case (Ampersand, RequiredFieldSelector(Identifier(v1)), TextLiteral(v2)) => TextLiteral("[" + v1 + "]" + v2)
      case _ => ???
    }
}
