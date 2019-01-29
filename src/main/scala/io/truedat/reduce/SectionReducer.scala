package io.truedat.reduce

import io.truedat.ast.{ Expression, LetExpression, Section, SectionMember }
import io.truedat.eval.Scope

trait SectionReducer extends Reducible {
  this: Section =>

  override def isReducible: Scope => Boolean = scope =>
    this.members.exists(_.isReducible(scope))

  override def isReduced: Boolean =
    this.members.forall(_.isReduced)

  override def reduce: Scope => Expression = scope => {
    this.members.indexWhere(_.isReducible(scope)) match {
      case -1 =>
        this.trace
        throw new IllegalArgumentException("No reducible members")
      case i =>
        val reducedMembers = this.members.splitAt(i) match {
          case (init, v :: tail) =>
            init ::: v.reduce(scope).asInstanceOf[SectionMember] :: tail
        }
        this.copy(members = reducedMembers)
    }
  }

  def trace: Unit =
    this.members.filterNot(_.isReduced) match {
      case SectionMember(_, expression: LetExpression, _, _) :: _ =>
        expression.variableList.variables.filterNot(_.isReduced).foreach(v => logger.warn(v.toString))
      case m =>
        logger.warn(m.toString)
    }

}
