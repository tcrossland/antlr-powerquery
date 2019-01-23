package io.truedat;

import org.antlr.v4.runtime.tree.ParseTreeWalker;

import java.io.IOException;

public class PowerQueryParserListener extends PowerQueryParser {
    public static void main(String[] args) throws IOException {
        String fileName = args[0];
        PowerQueryParserListener parser = new PowerQueryParserListener();
        PowerQueryFormulaParser.SectionDocumentContext ctx = parser.parseFile(fileName);
        PowerQueryFormulaParserListener listener = new PowerQueryListener();
        ParseTreeWalker walker = new ParseTreeWalker();
        walker.walk(listener, ctx);
    }
}
