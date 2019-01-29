package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope

trait SectionReducer extends Reducible {
  this: Section =>

  override def isReducible: Scope => Boolean = scope =>
    this.members.exists(_.isReducible(scope))

  override def isReduced: Boolean =
    this.members.forall(_.isReduced)

  override def reduce: Scope => Expression = scope => {
    this.members.indexWhere(_.isReducible(scope)) match {
      case i if i > -1 =>
        val reducedMembers = this.members.splitAt(i) match {
          case (init, v :: tail) =>
            init ::: v.reduce(scope).asInstanceOf[SectionMember] :: tail
        }
        this.copy(members = reducedMembers)
      case _ =>
        logger.warn("No item is reducible in " + this.toString)
        trace
        throw new IllegalArgumentException("No reducible members")
    }
  }

  override def nextReducible: Scope => Option[Expression] = scope =>
    this.members.find(_.isReducible(scope)).flatMap(_.nextReducible(scope))

  def trace(): Unit =
    this.members.filterNot(_.isReduced).foreach(traceMember)

  def traceMember: SectionMember => Unit = {
    case SectionMember(Identifier(id), expression: LetExpression, _, _) =>
      expression.variableList.variables.filterNot(_.isReduced).foreach(v => logger.warn(id + "::" + v.name.id + " -> " + v.expression.toString))
    case _ => ???
  }

}
