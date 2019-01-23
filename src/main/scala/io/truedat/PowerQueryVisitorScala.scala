package io.truedat

import com.typesafe.scalalogging.Logger
import io.truedat.PowerQueryFormulaParser._
import io.truedat.model.Node
import io.truedat.model.expression.{ RelationalExpression, _ }
import io.truedat.model.field.LiteralField
import io.truedat.model.identifier.Identifier
import io.truedat.model.item.{ Item, ItemList, Sequence }
import io.truedat.model.literal.{ NullLiteral, _ }
import org.antlr.v4.runtime.tree.{ ParseTree, ParseTreeProperty, TerminalNode }

import scala.collection.JavaConverters._
import scala.collection.immutable.ListMap
import scala.collection.mutable

class PowerQueryVisitorScala extends PowerQueryFormulaParserBaseVisitor[Node] {

  val logger: Logger = Logger[PowerQueryVisitorScala]

  private val values: ParseTreeProperty[Node] = new ParseTreeProperty[Node]()

  private def setValue(node: ParseTree, value: Node): Unit = values.put(node, value)

  private def getValue(node: ParseTree): Node = values.get(node)

  private def readGeneralizedIdentifier(node: TerminalNode): Identifier =
    Identifier(node.getSymbol.getText.trim)

  private def readOptionalIdentifier(node: TerminalNode): Option[Identifier] = {
    node match {
      case null => None
      case _ => Some(readIdentifier(node))
    }
  }

  private def readIdentifier(node: TerminalNode): Identifier = Identifier(node.getSymbol.getText)

  private def readTextLiteral(node: TerminalNode): TextLiteral =
    TextLiteral(node.getSymbol.getText)

  private def readNumberLiteral(node: TerminalNode): NumberLiteral =
    NumberLiteral(node.getSymbol.getText)


  override def visitSectionDocument(ctx: SectionDocumentContext): Section = visitSection(ctx.section())

  override def visitSection(ctx: SectionContext): Section = {
    val attributes: Option[RecordLiteral] = ctx.literalAttributes() match {
      case null => None
      case r => Some(visitLiteralAttributes(r))
    }

    val members: List[SectionMember] = ctx.sectionMember().asScala.map(visitSectionMember).toList
    val name: Option[Identifier] = readOptionalIdentifier(ctx.IDENTIFIER())
    val section = Section(name, members, attributes)
    logger.info(section.toString)
    section
  }

  override def visitSectionMember(ctx: SectionMemberContext): SectionMember = {
    val attributes: Option[RecordLiteral] = ctx.literalAttributes() match {
      case null => None
      case r => Some(visitLiteralAttributes(r))
    }
    val name: Identifier = readIdentifier(ctx.IDENTIFIER())
    val expression: Expression = visitExpression(ctx.expression())
    val shared: Boolean = ctx.SHARED() != null
    SectionMember(name, expression, shared, attributes)
  }

  override def visitLiteralAttributes(ctx: LiteralAttributesContext): RecordLiteral =
    visitRecordLiteral(ctx.recordLiteral())

  override def visitLetExpression(ctx: LetExpressionContext): LetExpression = {
    val expression: Expression = visit(ctx.expression()).asInstanceOf[Expression]
    val variableList: Node = visit(ctx.variableList())
    LetExpression(variableList, expression)
  }

  override def visitVariableList(ctx: VariableListContext): Node = {
    val variables: List[Variable] = ctx.variable().asScala.map(visitVariable).toList
    VariableList(variables)
  }

  override def visitVariable(ctx: VariableContext): Variable = {
    val name: Identifier = visitVariableName(ctx.variableName())
    val expression: Expression = visitExpression(ctx.expression())
    Variable(name, expression)
  }

  override def visitVariableName(ctx: VariableNameContext): Identifier = {
    readOptionalIdentifier(ctx.IDENTIFIER()).getOrElse(
      readGeneralizedIdentifier(ctx.GENERALIZED_IDENTIFIER())
    )
  }

  override def visitExpression(ctx: ExpressionContext): Expression =
    super.visitExpression(ctx).asInstanceOf[Expression]

  override def visitLogicalLiteral(ctx: LogicalLiteralContext): LogicalLiteral =
    ctx.FALSE() match {
      case null => TrueLiteral
      case _ => FalseLiteral
    }

  override def visitNullLiteral(ctx: NullLiteralContext): Literal =
    NullLiteral

  override def visitNumberLiteral(ctx: NumberLiteralContext): NumberLiteral =
    readNumberLiteral(ctx.NUMBER_LITERAL())

  override def visitTextLiteral(ctx: TextLiteralContext): TextLiteral =
    readTextLiteral(ctx.TEXT_LITERAL())

  override def visitListLiteral(ctx: ListLiteralContext): ListLiteral =
    visitLiteralItemList(ctx.literalItemList())

  override def visitLiteralItemList(ctx: LiteralItemListContext): ListLiteral = {
    val list = ctx.anyLiteral().asScala.map(visit).toList
    ListLiteral(list)
  }

  override def visitRecordLiteral(ctx: RecordLiteralContext): RecordLiteral =
    visitLiteralFieldList(ctx.literalFieldList())

  override def visitLiteralFieldList(ctx: LiteralFieldListContext): RecordLiteral = {
    val list = ctx.literalField().asScala.map(visit).toList
    RecordLiteral(list)
  }

  override def visitLiteralField(ctx: LiteralFieldContext): LiteralField = {
    val fieldName: Identifier = visitFieldName(ctx.fieldName())
    val value: Literal = visitAnyLiteral(ctx.anyLiteral())
    LiteralField(fieldName, value)
  }

  override def visitAnyLiteral(ctx: AnyLiteralContext): Literal =
    super.visitAnyLiteral(ctx).asInstanceOf[Literal]

  override def visitLiteralExpression(ctx: LiteralExpressionContext): Expression = {
    val literal: Literal = visitAnyLiteral(ctx.anyLiteral())
    LiteralExpression(literal)
  }

  override def visitListExpression(ctx: ListExpressionContext): Expression = {
    val list: ItemList = visitItemList(ctx.itemList())
    ListExpression(list)
  }

  override def visitItemList(ctx: ItemListContext): ItemList = {
    val items: List[Item] = ctx.item().asScala.map(visit).map(x => x.asInstanceOf[Item]).toList
    ItemList(items)
  }

  override def visitRecordExpression(ctx: RecordExpressionContext): Expression = {
    val fieldList: FieldList = visitFieldList(ctx.fieldList())
    RecordExpression(fieldList)
  }

  override def visitFieldList(ctx: FieldListContext): FieldList = {
    val fields: List[Field] = ctx match {
      case null => List.empty[Field]
      case _ => ctx.field().asScala.map(visitField).toList
    }
    FieldList(fields)
  }

  override def visitField(ctx: FieldContext): Field = {
    val fieldName: Identifier = visitFieldName(ctx.fieldName())
    val expression: Expression = visit(ctx.expression()).asInstanceOf[Expression]
    Field(fieldName, expression)
  }

  override def visitFieldName(ctx: FieldNameContext): Identifier = {
    readOptionalIdentifier(ctx.IDENTIFIER()).getOrElse(
      readGeneralizedIdentifier(ctx.GENERALIZED_IDENTIFIER())
    )
  }

  override def visitIdentifierExpression(ctx: IdentifierExpressionContext): Expression = {
    val identifier = readIdentifier(ctx.IDENTIFIER())
    IdentifierExpression(identifier)
  }

  override def visitSectionAccessExpression(ctx: SectionAccessExpressionContext): Expression = {
    val section = readIdentifier(ctx.IDENTIFIER(0))
    val identifier = readIdentifier(ctx.IDENTIFIER(1))
    SectionAccessExpression(section, identifier)
  }

  override def visitParenthesizedExpression(ctx: ParenthesizedExpressionContext): Expression = {
    visit(ctx.expression()).asInstanceOf[Expression]
  }

  override def visitItemAccessExpression(ctx: ItemAccessExpressionContext): Expression = {
    val expression: Expression = visit(ctx.primaryExpression()).asInstanceOf[Expression]
    val itemSelector: Expression = visitItemSelector(ctx.itemSelector())
    val optional = ctx.QUESTION() != null
    ItemSelection(expression, itemSelector, optional)
  }

  override def visitItemSelector(ctx: ItemSelectorContext): Expression = {
    visit(ctx.expression()).asInstanceOf[Expression]
  }

  override def visitInvokeExpression(ctx: InvokeExpressionContext): Expression = {
    val expression: Expression = visit(ctx.primaryExpression()).asInstanceOf[Expression]
    val argumentList: ArgumentList = visitArgumentList(ctx.argumentList())
    InvokeExpression(expression, argumentList)
  }

  override def visitArgumentList(ctx: ArgumentListContext): ArgumentList = {
    val expressions: List[Expression] = ctx match {
      case null => List.empty[Expression]
      case _ => ctx.expression().asScala.map(visit).map(x => x.asInstanceOf[Expression]).toList
    }
    ArgumentList(expressions)
  }

  override def visitSequence(ctx: SequenceContext): Sequence = {
    val from: Expression = visitExpression(ctx.expression(0))
    val to: Expression = visitExpression(ctx.expression(1))
    Sequence(from, to)
  }

  override def visitSingleItem(ctx: SingleItemContext): Item = {
    val expr: Expression = visitExpression(ctx.expression())
    Item(expr)
  }

  override def visitLogicalOrExpression(ctx: LogicalOrExpressionContext): Expression = {
    val expressions: List[Expression] = ctx.logicalAndExpression().asScala.map(visitLogicalAndExpression).toList
    if (expressions.length > 2) logger.info(LogicalOrExpression(expressions).toString)
    if (expressions.length > 1) LogicalOrExpression(expressions) else expressions.head
  }

  override def visitLogicalAndExpression(ctx: LogicalAndExpressionContext): Expression = {
    val expressions = ctx.isExpression().asScala.map(visitIsExpression).toList
    if (expressions.length > 2) logger.info(LogicalAndExpression(expressions).toString)
    if (expressions.length > 1) LogicalAndExpression(expressions) else expressions.head
  }

  override def visitIsExpression(ctx: IsExpressionContext): Expression = {
    val asExpression: Expression = visitAsExpression(ctx.asExpression())
    if (ctx.IS().isEmpty) asExpression else IsExpression(asExpression)
  }

  override def visitAsExpression(ctx: AsExpressionContext): Expression = {
    val equalityExpression: Expression = visitEqualityExpression(ctx.equalityExpression())
    if (ctx.AS().isEmpty) equalityExpression else AsExpression(equalityExpression)
  }

  override def visitEqualityExpression(ctx: EqualityExpressionContext): Expression = {
    val expressions = ctx.relationalExpression().asScala.map(visitRelationalExpression).toList
    if (expressions.length > 2) logger.info(EqualityExpression(expressions).toString)
    if (expressions.length > 1) EqualityExpression(expressions) else expressions.head
  }

  override def visitRelationalExpression(ctx: RelationalExpressionContext): Expression = {
    val expressions = ctx.additiveExpression().asScala.map(visitAdditiveExpression).toList
    if (expressions.length > 2) logger.info(RelationalExpression(expressions).toString)
    if (expressions.length > 1) RelationalExpression(expressions) else expressions.head
  }

  override def visitAdditiveExpression(ctx: AdditiveExpressionContext): Expression = {
    val expressions = ctx.multiplicativeExpression().asScala.map(visitMultiplicativeExpression).toList
    if (expressions.length > 2) logger.info(AdditiveExpression(expressions).toString)
    if (expressions.length > 1) AdditiveExpression(expressions) else expressions.head
  }

  override def visitMultiplicativeExpression(ctx: MultiplicativeExpressionContext): Expression = {
    val expressions = ctx.metaExpression().asScala.map(visitMetaExpression).toList
    if (expressions.length > 2) logger.info(MultiplicativeExpression(expressions).toString)
    if (expressions.length > 1) MultiplicativeExpression(expressions) else expressions.head
  }

  override def visitMetaExpression(ctx: MetaExpressionContext): Expression = {
    val expressions = ctx.unaryExpression().asScala.map(visitUnaryExpression).toList
    if (expressions.length > 2) logger.info(MetaExpression(expressions).toString)
    if (expressions.length > 1) MetaExpression(expressions) else expressions.head
  }

  override def visitUnaryExpression(ctx: UnaryExpressionContext): Expression = {
    ctx.typeExpression() match {
      case null => visitUnaryExpression(ctx.unaryExpression())
      case _ => visitTypeExpression(ctx.typeExpression())
    }
  }

  override def visitTypeExpression(ctx: TypeExpressionContext): Expression = {
    ctx.TYPE() match {
      case null => visit(ctx.primaryExpression()).asInstanceOf[Expression]
      case _ => TypeExpression
    }
  }

  override def visitFieldSelectionOrProjection(ctx: FieldSelectionOrProjectionContext): Node = {
    if (null != ctx.TEXT_LITERAL()) {
      val literal = readTextLiteral(ctx.TEXT_LITERAL())
      val selection = visit(ctx.fieldAccessExpression_LITERAL())
      FieldSelection(LiteralExpression(literal), selection)
    } else if (null != ctx.NUMBER_LITERAL()) {
      val literal = readNumberLiteral(ctx.NUMBER_LITERAL())
      val selection = visit(ctx.fieldAccessExpression_LITERAL())
      FieldSelection(LiteralExpression(literal), selection)
    } else if (null != ctx.OPEN_BRACE()) {
      visit(ctx.fieldAccessExpression_OPEN_BRACE())
    } else if (null != ctx.IDENTIFIER()) {
      val identifier = readIdentifier(ctx.IDENTIFIER())
      this.setValue(ctx.fieldAccessExpression_IDENTIFIER, IdentifierExpression(identifier))
      val selection = visit(ctx.fieldAccessExpression_IDENTIFIER())
      FieldSelection(IdentifierExpression(identifier), selection)
    } else if (null != ctx.AT()) {
      ???
    } else if (null != ctx.OPEN_PARENS()) {
      ???
    } else if (null != ctx.DOT_DOT_DOT()) {
      ???
    } else {
      ???
    }
  }

  override def visitFieldAccessExpression_LITERAL(ctx: FieldAccessExpression_LITERALContext): Node = {
    visit(ctx.fieldAccessExpression_primaryExpression())
  }

  override def visitFieldAccessExpression_OPEN_BRACE(ctx: FieldAccessExpression_OPEN_BRACEContext): FieldSelection = {
    val list: ItemList = visitItemList(ctx.itemList())
    val expression: Expression = ListExpression(list)
    val selection: Node = visit(ctx.fieldAccessExpression_primaryExpression())
    selection match {
      case FieldSelector(_, _) => FieldSelection(expression, selection)
      case Projection(_, _) => FieldSelection(expression, selection)
    }
  }

  override def visitFieldSelection(ctx: FieldSelectionContext): FieldSelector = {
    visitFieldSelector(ctx.fieldSelector())
  }

  override def visitFieldSelector(ctx: FieldSelectorContext): FieldSelector = {
    ctx.optionalFieldSelector() match {
      case null => visitRequiredFieldSelector(ctx.requiredFieldSelector())
      case _ => visitOptionalFieldSelector(ctx.optionalFieldSelector())
    }
  }

  override def visitOptionalFieldSelector(ctx: OptionalFieldSelectorContext): FieldSelector = {
    val fieldName: Identifier = visitFieldName(ctx.fieldName())
    FieldSelector(fieldName, optional = true)
  }

  override def visitProjection(ctx: ProjectionContext): Projection = {
    val optional = ctx.QUESTION() != null
    val selectorList: SelectorList = visitRequiredSelectorList(ctx.requiredSelectorList())
    Projection(selectorList, optional)
  }

  override def visitRequiredSelectorList(ctx: RequiredSelectorListContext): SelectorList = {
    val requiredFieldSelectors = ctx.requiredFieldSelector().asScala.map(visitRequiredFieldSelector).toList
    SelectorList(requiredFieldSelectors)
  }

  override def visitRequiredFieldSelector(ctx: RequiredFieldSelectorContext): FieldSelector = {
    val fieldName: Identifier = visitFieldName(ctx.fieldName())
    FieldSelector(fieldName)
  }

  override def visitFieldAccessExpression_primaryExpression_invokeExpression(ctx: FieldAccessExpression_primaryExpression_invokeExpressionContext): Node = ???

  override def visitFieldAccessExpression_primaryExpression_itemAccessExpression(ctx: FieldAccessExpression_primaryExpression_itemAccessExpressionContext): Node = {
    val optional = ctx.QUESTION() != null
    val itemSelector: Expression = visitItemSelector(ctx.itemSelector())
    val itemAccessExpression: ItemSelection =
      ItemSelection(getValue(ctx.parent).asInstanceOf[Expression], itemSelector, optional)

    val selection = visit(ctx.fieldAccessExpression_primaryExpression())
    FieldSelection(itemAccessExpression, selection)
  }

  override def visitRecordExpression_fieldAccess(ctx: RecordExpression_fieldAccessContext): Node = ???

  override def visitImplicitTargetFieldSelection(ctx: ImplicitTargetFieldSelectionContext): ImplicitTargetFieldSelection = {
    val optional = ctx.QUESTION() != null
    val fieldName: Identifier = visitFieldName(ctx.fieldName())
    ImplicitTargetFieldSelection(FieldSelector(fieldName, optional))
  }

  override def visitIntrinsicFunctionExpression(ctx: IntrinsicFunctionExpressionContext): Node = {
    if (null != ctx.HASH_TABLE())
      IntrinsicTableFunction
    else
      ???
  }

  override def visitEachExpression(ctx: EachExpressionContext): EachExpression = {
    val functionBody: Expression = visit(ctx.eachExpressionBody()).asInstanceOf[Expression]
    EachExpression(functionBody)
  }

  override def visitFunctionExpression(ctx: FunctionExpressionContext): Node = {
    val parameterList = visit(ctx.parameterList())
    val returnType: Option[Type] = ctx.returnType() match {
      case null => None
      case t => Some(visitReturnType(t))
    }
    val functionBody: Expression = visit(ctx.functionBody()).asInstanceOf[Expression]
    // logger.info(FunctionExpression(parameterList, returnType, functionBody).toString)
    FunctionExpression(parameterList, returnType, functionBody)
  }

  override def visitParameterList(ctx: ParameterListContext): Node = {
    val optionalParameterList = ctx.optionalParameterList() match {
      case null => None
      case o => Some(visitOptionalParameterList(o))
    }
    val fixedParameterList = ctx.fixedParameterList() match {
      case null => None
      case o => Some(visitFixedParameterList(o))
    }
    ParameterList(fixedParameterList, optionalParameterList)
  }

  override def visitFixedParameterList(ctx: FixedParameterListContext): FixedParameterList = {
    val parameters = ctx match {
      case null => List.empty[Parameter]
      case _ => ctx.parameter().asScala.map(visitParameter).toList

    }
    FixedParameterList(parameters)
  }

  override def visitOptionalParameterList(ctx: OptionalParameterListContext): OptionalParameterList = {
    val parameters = ctx match {
      case null => List.empty[Parameter]
      case _ => ctx.optionalParameter().asScala.map(visitOptionalParameter).toList

    }
    OptionalParameterList(parameters)
  }

  override def visitParameter(ctx: ParameterContext): Parameter = {
    val parameterName: Identifier = visitParameterName(ctx.parameterName())
    val parameterType: Option[Type] = ctx.parameterType() match {
      case null => None
      case t =>
        Some(visitParameterType(t))
    }
    Parameter(parameterName, parameterType)
  }

  override def visitOptionalParameter(ctx: OptionalParameterContext): Parameter = {
    visitParameter(ctx.parameter())
  }

  override def visitParameterName(ctx: ParameterNameContext): Identifier = {
    readIdentifier(ctx.IDENTIFIER())
  }

  override def visitParameterType(ctx: ParameterTypeContext): Type = {
    visitAssertion(ctx.assertion())
  }

  override def visitReturnType(ctx: ReturnTypeContext): Type = {
    visitAssertion(ctx.assertion())
  }

  override def visitAssertion(ctx: AssertionContext): Type = {
    visitType(ctx.`type`())
  }

  override def visitType(ctx: TypeContext): Type = {
    if (null != ctx.primaryType())
      visitPrimaryType(ctx.primaryType())
    else
      ExpressionType(visitExpression(ctx.expression()))
  }

  override def visitPrimaryType(ctx: PrimaryTypeContext): Type = {
    super.visitPrimaryType(ctx).asInstanceOf[Type]
  }

  override def visitTableType(ctx: TableTypeContext): Node = ???

  override def visitRecordType(ctx: RecordTypeContext): Node = ???

  override def visitListType(ctx: ListTypeContext): Node = ???

  override def visitFunctionType(ctx: FunctionTypeContext): Node = ???

  override def visitNullableType(ctx: NullableTypeContext): Node = ???

  override def visitPrimitiveType(ctx: PrimitiveTypeContext): Type = {
    val cond = ListMap(
      (() => null != ctx.ANY()) -> AnyType,
      (() => null != ctx.ANYNONNULL()) -> AnyNonNullType,
      (() => null != ctx.BINARY()) -> BinaryType,
      (() => null != ctx.DATE()) -> DateType,
      (() => null != ctx.DATETIME()) -> DateTimeType,
      (() => null != ctx.DATETIMEZONE()) -> DateTimeZoneType,
      (() => null != ctx.DURATION()) -> DurationType,
      (() => null != ctx.FUNCTION()) -> FunctionType,
      (() => null != ctx.LIST()) -> ListType,
      (() => null != ctx.LOGICAL()) -> LogicalType,
      (() => null != ctx.NONE()) -> NoneType,
      (() => null != ctx.NULL()) -> NullType,
      (() => null != ctx.NUMBER()) -> NumberType,
      (() => null != ctx.RECORD()) -> RecordType,
      (() => null != ctx.TABLE()) -> TableType,
      (() => null != ctx.TEXT()) -> TextType,
      (() => null != ctx.TYPE()) -> TypeType
    )

    cond.find(_._1()).map(_._2).getOrElse(???)
  }
}
