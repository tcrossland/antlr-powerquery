package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope
import org.scalatest.FlatSpec

class LetExpressionReducerSpec extends FlatSpec {

  private def fixture= new {
    val functionId = "Sql.Database"
    val hostName = "some.database.windows.net"

    val identifier = Identifier(functionId)

    val scope: Scope = Scope.fromMap(
      Map(Identifier("server") -> TextLiteral(hostName))
    )

    val argumentList = ArgumentList(
      List(IdentifierExpression(Identifier("server")))
    )

    val invokeExpression = InvokeExpression(IdentifierExpression(identifier), argumentList)

    val variableList = VariableList(
      List(
        Variable(Identifier("Source"), invokeExpression),
        Variable(Identifier("SourceRef"), IdentifierExpression(Identifier("Source")))
      )
    )
    val letExpression = LetExpression(
      variableList,
      IdentifierExpression(Identifier("SourceRef"))
    )
  }

  "A let expression" should "be reducible if any of its variables is reducible" in {
    val f = fixture

    val scope = Scope.extend(f.scope, f.letExpression)
    assert(f.letExpression.isReducible(scope))
  }

  it should "reduce correctly" in {
    val f = fixture
    val e1 = f.letExpression.reduce(f.scope)
    assert(e1 ==
      LetExpression(
        VariableList(
          List(
            Variable(
              Identifier("Source"),
              InvokeExpression(
                IdentifierExpression(Identifier(f.functionId)),
                ArgumentList(List(TextLiteral(f.hostName)))
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
    assert(e1.isReducible(f.scope))
    val e2 = e1.reduce(f.scope)
    assert(e2 ==
      LetExpression(
        VariableList(
          List(
            Variable(
              Identifier("Source"),
              DataSource(f.functionId, List(TextLiteral(f.hostName)))
            ),
            Variable(
              Identifier("SourceRef"),
              IdentifierExpression(Identifier("Source"))
            )
          )
        ),
        IdentifierExpression(Identifier("SourceRef")))
    )

    assert(e2.isReducible(f.scope))
    val e3 = e2.reduce(f.scope)
    assert(e3 ==
      LetExpression(
        VariableList(
          List(
            Variable(
              Identifier("Source"),
              DataSource(f.functionId, List(TextLiteral(f.hostName)))
            ),
            Variable(
              Identifier("SourceRef"),
              DataSource(f.functionId, List(TextLiteral(f.hostName)))
            )
          )
        ),
        IdentifierExpression(Identifier("SourceRef")))
    )

    assert(e3.isReducible(Scope.extend(f.scope, e3)))
    val e4 = e3.reduce(Scope.extend(f.scope, e3))
    assert(e4 ==
      DataSource(f.functionId, List(TextLiteral(f.hostName)))
    )

    assert(e4.isReduced)
  }
}
