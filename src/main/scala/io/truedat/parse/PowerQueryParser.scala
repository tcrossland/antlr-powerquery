package io.truedat.parse

import io.truedat.{ PowerQueryFormulaLexer, PowerQueryFormulaParser }
import org.antlr.v4.runtime.{ CharStreams, CommonTokenStream }

trait PowerQueryParser {
  def parseFile(fileName: String): PowerQueryFormulaParser.SectionDocumentContext = {
    val input = CharStreams.fromFileName(fileName)
    val lexer = new PowerQueryFormulaLexer(input)
    lexer.setInputStream(input)
    val tokens = new CommonTokenStream(lexer)
    val parser = new PowerQueryFormulaParser(tokens)
    parser.sectionDocument
  }
}
