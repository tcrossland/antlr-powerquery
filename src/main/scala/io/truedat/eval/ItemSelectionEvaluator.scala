package io.truedat.eval

import io.truedat.ast.{ DataSource, Expression, ItemSelection }

trait ItemSelectionEvaluator extends Evaluable {
  this: ItemSelection =>

  override def isEvaluable: Scope => Boolean = _ =>
    expression.isReduced && itemSelector.isReduced

  override def evaluate: Scope => Expression = _ =>
    this.expression match {
      case d: DataSource =>
        d.evaluate(this.itemSelector)
      case _ =>
        ???
    }
}
