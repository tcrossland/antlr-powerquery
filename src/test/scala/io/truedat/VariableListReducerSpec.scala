package io.truedat

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class VariableListReducerSpec extends FlatSpec {
  val functionId = "Sql.Database"
  val hostName = "some.database.windows.net"
  val identifier = Identifier(functionId)
  val bindings: Map[Identifier, Expression] = Map(
    Identifier("server") -> TextLiteral(hostName)
  )
  val argumentList = ArgumentList(
    List(
      IdentifierExpression(Identifier("server"))
    )
  )
  val invokeExpression = InvokeExpression(IdentifierExpression(identifier), argumentList)
  val variableList = VariableList(
    List(
      Variable(Identifier("Source"), invokeExpression),
      Variable(Identifier("SourceRef"), IdentifierExpression(Identifier("Source")))
    )
  )
  val parentScope: Scope = new Scope(None, bindings)

  "A variable list" should "be reducible if it's variables are reducible" in {
    val scope = Scope.extend(parentScope, variableList)
    assert(variableList.isReducible(scope))
  }

  it should "reduce correctly" in {
    val e1: VariableList = variableList.reduce(Scope.extend(parentScope, variableList)).asInstanceOf[VariableList]
    assert(e1 ==
      VariableList(
        List(
          Variable(
            Identifier("Source"),
            InvokeExpression(
              IdentifierExpression(Identifier(functionId)),
              ArgumentList(List(TextLiteral(hostName)))
            )
          ),
          Variable(Identifier("SourceRef"), IdentifierExpression(Identifier("Source")))
        )
      )
    )
    assert(e1.isReducible(Scope.extend(parentScope, e1)))
    val e2: VariableList = e1.reduce(Scope.extend(parentScope, e1)).asInstanceOf[VariableList]
    assert(e2 ==
      VariableList(
        List(
          Variable(
            Identifier("Source"),
            DataSource(
              functionId,
              List(TextLiteral(hostName))
            )
          ),
          Variable(Identifier("SourceRef"), IdentifierExpression(Identifier("Source")))
        )
      )
    )
    assert(e2.isReducible(Scope.extend(parentScope, e2)))
    val e3: VariableList = e2.reduce(Scope.extend(parentScope, e2)).asInstanceOf[VariableList]
    assert(e3 == VariableList(
      List(
        Variable(
          Identifier("Source"),
          DataSource(
            functionId,
            List(TextLiteral(hostName))
          )
        ),
        Variable(
          Identifier("SourceRef"),
          DataSource(
            functionId,
            List(TextLiteral(hostName))
          )
        )
      )
    )
    )
    assert(e3.isReduced)
  }
}
