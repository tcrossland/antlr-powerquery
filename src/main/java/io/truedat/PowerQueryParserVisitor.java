package io.truedat;

import java.io.IOException;

public class PowerQueryParserVisitor extends PowerQueryParser {
    public static void main(String[] args) throws IOException {
        String fileName = args[0];
        PowerQueryParserVisitor parser = new PowerQueryParserVisitor();
        PowerQueryFormulaParser.SectionDocumentContext ctx = parser.parseFile(fileName);
        PowerQueryVisitor visitor = new PowerQueryVisitor();
        visitor.visit(ctx);
    }
}
