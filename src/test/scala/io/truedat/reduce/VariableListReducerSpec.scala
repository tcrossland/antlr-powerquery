package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope
import io.truedat.functions.`Sql.Database`
import org.scalatest.FlatSpec

class VariableListReducerSpec extends FlatSpec {
  import scala.language.reflectiveCalls

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
  }

  "A variable list" should "be reducible if any of its variables is reducible" in {
    val f = fixture

    assert(f.variableList.isReducible(f.scope))
  }

  it should "reduce correctly" in {
    val f = fixture
    val e1 = f.variableList.reduce(f.scope)
    assert(e1 ==
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
      )
    )
    assert(e1.isReducible(f.scope))
    val e2 = e1.reduce(f.scope)
    assert(e2 ==
      VariableList(
        List(
          Variable(
            Identifier("Source"),
            `Sql.Database`(List(TextLiteral(f.hostName)))
          ),
          Variable(
            Identifier("SourceRef"),
            IdentifierExpression(Identifier("Source"))
          )
        )
      ),
    )

    assert(e2.isReducible(f.scope))
    val e3 = e2.reduce(f.scope)
    assert(e3 ==
      VariableList(
        List(
          Variable(
            Identifier("Source"),
            `Sql.Database`(List(TextLiteral(f.hostName)))
          ),
          Variable(
            Identifier("SourceRef"),
            `Sql.Database`(List(TextLiteral(f.hostName)))
          )
        )
      ),
    )

    assert(e3.isReduced)
  }
}
