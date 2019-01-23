package io.truedat;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PowerQueryListener extends PowerQueryFormulaParserBaseListener {
    public static Logger log = LoggerFactory.getLogger(PowerQueryListener.class);

    @Override
    public void exitNotImplementedExpression(PowerQueryFormulaParser.NotImplementedExpressionContext ctx) {
        super.exitNotImplementedExpression(ctx);
    }

    @Override
    public void exitParenthesizedExpression(PowerQueryFormulaParser.ParenthesizedExpressionContext ctx) {
        super.exitParenthesizedExpression(ctx);
    }

    @Override
    public void exitBuiltinFunctionExpression(PowerQueryFormulaParser.BuiltinFunctionExpressionContext ctx) {
        super.exitBuiltinFunctionExpression(ctx);
    }

    /*
    @Override
    public void exitFieldAccessExpression(PowerQueryFormulaParser.FieldAccessExpressionContext ctx) {
        super.exitFieldAccessExpression(ctx);
    }
    */

    @Override
    public void exitIdentifierExpression(PowerQueryFormulaParser.IdentifierExpressionContext ctx) {
        log.info(ctx.IDENTIFIER().toString());
        super.exitIdentifierExpression(ctx);
    }

    @Override
    public void exitItemAccessExpression(PowerQueryFormulaParser.ItemAccessExpressionContext ctx) {
        super.exitItemAccessExpression(ctx);
    }

    @Override
    public void exitSectionAccessExpression(PowerQueryFormulaParser.SectionAccessExpressionContext ctx) {
        super.exitSectionAccessExpression(ctx);
    }

    @Override
    public void exitLiteralExpression(PowerQueryFormulaParser.LiteralExpressionContext ctx) {
        super.exitLiteralExpression(ctx);
    }

    @Override
    public void exitListExpression(PowerQueryFormulaParser.ListExpressionContext ctx) {
        super.exitListExpression(ctx);
    }

    @Override
    public void exitInvokeExpression(PowerQueryFormulaParser.InvokeExpressionContext ctx) {
        super.exitInvokeExpression(ctx);
    }
}
