package io.truedat;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;

import java.io.IOException;

public abstract class PowerQueryParser {
    public PowerQueryFormulaParser.SectionDocumentContext parseFile(String fileName) throws IOException {
        CharStream input = CharStreams.fromFileName(fileName);
        PowerQueryFormulaLexer lexer = new PowerQueryFormulaLexer(input);
        lexer.setInputStream(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        PowerQueryFormulaParser parser = new PowerQueryFormulaParser(tokens);
        return parser.sectionDocument();
    }
}
