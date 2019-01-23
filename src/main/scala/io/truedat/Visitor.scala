package io.truedat

import io.truedat.PowerQueryFormulaParser.SectionDocumentContext

object Visitor extends App {
  val fileName: String = args.head
  val parser: PowerQueryParser = new PowerQueryParser {}
  val ctx: SectionDocumentContext = parser.parseFile(args.head)
  val visitor: PowerQueryVisitorScala = new PowerQueryVisitorScala()
  visitor.visit(ctx)
}
