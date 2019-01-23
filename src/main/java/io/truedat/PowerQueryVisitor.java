package io.truedat;

public class PowerQueryVisitor extends PowerQueryFormulaParserBaseVisitor {
    @Override
    public Object visitInvokeExpression(PowerQueryFormulaParser.InvokeExpressionContext ctx) {
        return super.visitInvokeExpression(ctx);
    }

    @Override
    public Object visitLogicalLiteral(PowerQueryFormulaParser.LogicalLiteralContext ctx) {
        return null == ctx.FALSE();
    }

    @Override
    public Object visitNumberLiteral(PowerQueryFormulaParser.NumberLiteralContext ctx) {
        return ctx.NUMBER_LITERAL().getSymbol().getText();
    }

    @Override
    public Object visitTextLiteral(PowerQueryFormulaParser.TextLiteralContext ctx) {
        return ctx.TEXT_LITERAL().getSymbol().getText();
    }

    @Override
    public Object visitNullLiteral(PowerQueryFormulaParser.NullLiteralContext ctx) {
        return null;
    }

    @Override
    public Object visitRecordLiteral(PowerQueryFormulaParser.RecordLiteralContext ctx) {
        return super.visitRecordLiteral(ctx);
    }

    @Override
    public Object visitListLiteral(PowerQueryFormulaParser.ListLiteralContext ctx) {
        return super.visitListLiteral(ctx);
    }
}
