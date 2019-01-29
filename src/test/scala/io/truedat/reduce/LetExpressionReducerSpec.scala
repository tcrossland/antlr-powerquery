package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class LetExpressionReducerSpec extends FlatSpec {
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
  val letExpression = LetExpression(
    variableList,
    IdentifierExpression(Identifier("SourceRef"))
  )

  "A let expression" should "be reducible if it's variables are reducible" in {
    val scope = Scope.extend(parentScope, letExpression)
    assert(letExpression.isReducible(scope))
  }

  it should "reduce correctly" in {
    val e1 = letExpression.reduce(Scope.extend(parentScope, letExpression))
    assert(e1 ==
      LetExpression(
        VariableList(
          List(
            Variable(
              Identifier("Source"),
              InvokeExpression(
                IdentifierExpression(Identifier("Sql.Database")),
                ArgumentList(List(TextLiteral(hostName)))
              )
            ),
            Variable(
              Identifier("SourceRef"),
              IdentifierExpression(Identifier("Source"))
            )
          )
        ),
        IdentifierExpression(Identifier("SourceRef")))
    )
    assert(e1.isReducible(Scope.extend(parentScope, e1)))
    val e2 = e1.reduce(Scope.extend(parentScope, e1))
    assert(e2 ==
      LetExpression(
        VariableList(
          List(
            Variable(
              Identifier("Source"),
              DataSource("Sql.Database", List(TextLiteral(hostName)))
            ),
            Variable(
              Identifier("SourceRef"),
              IdentifierExpression(Identifier("Source"))
            )
          )
        ),
        IdentifierExpression(Identifier("SourceRef")))
    )

    assert(e2.isReducible(Scope.extend(parentScope, e2)))
    val e3 = e2.reduce(Scope.extend(parentScope, e2))
    assert(e3 ==
      LetExpression(
        VariableList(
          List(
            Variable(
              Identifier("Source"),
              DataSource("Sql.Database", List(TextLiteral(hostName)))
            ),
            Variable(
              Identifier("SourceRef"),
              DataSource("Sql.Database", List(TextLiteral(hostName)))
            )
          )
        ),
        IdentifierExpression(Identifier("SourceRef")))
    )

    assert(e3.isReducible(Scope.extend(parentScope, e3)))
    val e4 = e3.reduce(Scope.extend(parentScope, e3))
    assert(e4 ==
      DataSource("Sql.Database", List(TextLiteral(hostName)))
    )

    assert(e4.isReduced)
  }
}
