package io.truedat

import com.typesafe.scalalogging.Logger
import io.truedat.PowerQueryFormulaParser._
import io.truedat.ast._
import io.truedat.csv.Writer
import io.truedat.eval.Scope
import io.truedat.extract.DictionaryContext
import io.truedat.parse.PowerQueryParser
import org.antlr.v4.runtime.tree.{ ParseTree, ParseTreeProperty, TerminalNode }

import scala.collection.JavaConverters._
import scala.collection.immutable.ListMap

object PowerQueryVisitor extends App with PowerQueryParser {
  val logger: Logger = Logger[PowerQueryVisitor]

  args.foreach(visitFile)

  def visitFile(fileName: String) = {
    val reportName = fileName.split("/").last.replaceAll("_", " ").replaceAll(".m$", "")

    logger.info("▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ Analyzing " + reportName + " ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒")
    val ctx: SectionDocumentContext = this.parseFile(fileName)
    val visitor: PowerQueryVisitor = new PowerQueryVisitor()
    val doc: Section = visitor.visit(ctx).asInstanceOf[Section]

    var section: Section = doc
    var scope: Scope = Scope.create(section)
    while (!section.isReduced && section.isReducible(scope)) {
      logger.whenTraceEnabled {
        val n: Option[Expression] = section.nextReducible(scope)
        logger.trace(n.toString)
      }

      section = section.reduce(scope).asInstanceOf[Section]
      scope = Scope.create(section)
    }

    val tables = section.members
      .filter(_.expression.isInstanceOf[LineageElement])

    /*
    tables
      .map(e => (e.name.id, e.expression.toString))
      .sortBy(_._1)
      .foreach(x => logger.info(x._1 + " <- " + x._2))
    */


    val tablesWithFields: List[(String, Set[String])] = tables
      .map(m => (m.name.id, DictionaryContext.extractFields(m.expression)))

    val writer = new Writer("./data/output", "LaLiga", reportName)
    writer.write(tablesWithFields)

    tablesWithFields
      .sortBy(_._1)
      .foreach {
        case (name: String, fields: Set[String]) => logger.info(name + " CONTAINS " + fields.toList.sortBy(_.toLowerCase).mkString("[", ",", "]"))
      }
  }
}

class PowerQueryVisitor(autoReduce: Boolean = true) extends PowerQueryFormulaParserBaseVisitor[Node] {

  val logger: Logger = Logger[PowerQueryVisitor]

  private val values: ParseTreeProperty[Node] = new ParseTreeProperty[Node]()

  override def visitSectionDocument(ctx: SectionDocumentContext): Section = visitSection(ctx.section())

  override def visitSection(ctx: SectionContext): Section = {
    val attributes: Option[RecordLiteral] = ctx.literalAttributes() match {
      case null => None
      case r => Some(visitLiteralAttributes(r))
    }

    val members: List[SectionMember] = ctx.sectionMember().asScala.map(visitSectionMember).toList
    val name: Option[Identifier] = readOptionalIdentifier(ctx.IDENTIFIER())
    Section(name, members, attributes)
  }

  override def visitSectionMember(ctx: SectionMemberContext): SectionMember = {
    val attributes: Option[RecordLiteral] = if (autoReduce) {
      None
    } else {
      ctx.literalAttributes() match {
        case null => None
        case r => Some(visitLiteralAttributes(r))
      }
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
    val variableList: VariableList = visitVariableList(ctx.variableList())
    LetExpression(variableList, expression)
  }

  override def visitVariableList(ctx: VariableListContext): VariableList = {
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

  private def readGeneralizedIdentifier(node: TerminalNode): Identifier =
    Identifier(node.getSymbol.getText.trim)

  private def readOptionalIdentifier(node: TerminalNode): Option[Identifier] = {
    node match {
      case null => None
      case _ => Some(readIdentifier(node))
    }
  }

  private def readIdentifier(node: TerminalNode): Identifier =
    Identifier(unquote(node.getSymbol.getText))

  private def unquote: String => String = s =>
    s.charAt(0) match {
      case '#' => s.replaceFirst("^#\"", "").replaceFirst("\"$", "")
      case '"' => s.replaceFirst("^\"", "").replaceFirst("\"$", "")
      case _ => s
    }

  override def visitExpression(ctx: ExpressionContext): Expression =
    super.visitExpression(ctx).asInstanceOf[Expression]

  override def visitLogicalLiteral(ctx: LogicalLiteralContext): LogicalLiteral =
    ctx.FALSE() match {
      case null => TrueLiteral
      case _ => FalseLiteral
    }

  override def visitNullLiteral(ctx: NullLiteralContext): Value =
    NullLiteral

  override def visitNumberLiteral(ctx: NumberLiteralContext): NumberLiteral =
    readNumberLiteral(ctx.NUMBER_LITERAL())

  override def visitTextLiteral(ctx: TextLiteralContext): TextLiteral =
    readTextLiteral(ctx.TEXT_LITERAL())

  override def visitListLiteral(ctx: ListLiteralContext): ListLiteral =
    visitLiteralItemList(ctx.literalItemList())

  override def visitLiteralItemList(ctx: LiteralItemListContext): ListLiteral = {
    val list = ctx.anyLiteral().asScala.map(visitAnyLiteral).toList
    ListLiteral(list)
  }

  override def visitRecordLiteral(ctx: RecordLiteralContext): RecordLiteral =
    visitLiteralFieldList(ctx.literalFieldList())

  override def visitLiteralFieldList(ctx: LiteralFieldListContext): RecordLiteral = {
    val list = ctx.literalField().asScala.map(visitLiteralField).toList
    RecordLiteral(list)
  }

  override def visitLiteralField(ctx: LiteralFieldContext): LiteralField = {
    val fieldName: Identifier = visitFieldName(ctx.fieldName())
    val value: Value = visitAnyLiteral(ctx.anyLiteral())
    LiteralField(fieldName, value)
  }

  override def visitAnyLiteral(ctx: AnyLiteralContext): Value = {
    if (null != ctx.textLiteral()) {
      visitTextLiteral(ctx.textLiteral())
    } else {
      super.visitAnyLiteral(ctx).asInstanceOf[Value]
    }
  }

  override def visitFieldName(ctx: FieldNameContext): Identifier = {
    readOptionalIdentifier(ctx.IDENTIFIER()).getOrElse(
      readGeneralizedIdentifier(ctx.GENERALIZED_IDENTIFIER())
    )
  }

  override def visitLiteralExpression(ctx: LiteralExpressionContext): Expression = {
    val literal: Value = visitAnyLiteral(ctx.anyLiteral())
    if (autoReduce) literal else LiteralExpression(literal)
  }

  override def visitListExpression(ctx: ListExpressionContext): Expression = {
    val list: ItemList = visitItemList(ctx.itemList())
    if (this.autoReduce) list else ListExpression(list)
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
    ctx.QUESTION() match {
      case null => ItemSelection(expression, itemSelector)
      case _ => OptionalItemSelection(expression, itemSelector)
    }
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

  override def visitSingleItem(ctx: SingleItemContext): Expression = {
    visitExpression(ctx.expression())
  }

  override def visitLogicalOrExpression(ctx: LogicalOrExpressionContext): Expression = {
    val expressions: List[Expression] = ctx.logicalAndExpression().asScala.map(visitLogicalAndExpression).toList
    expressions.reduce((e1, e2) => LogicalOrExpression(e1, e2))
  }

  override def visitLogicalAndExpression(ctx: LogicalAndExpressionContext): Expression = {
    val expressions = ctx.isExpression().asScala.map(visitIsExpression).toList
    expressions.reduce((e1, e2) => LogicalAndExpression(e1, e2))
  }

  override def visitIsExpression(ctx: IsExpressionContext): Expression = {
    val asExpression: Expression = visitAsExpression(ctx.asExpression())
    val types = ctx.nullablePrimitiveType().asScala.map(visitNullablePrimitiveType).toList
    types.foldLeft(asExpression)(
      (e, is) => IsExpression(e, is)
    )
  }

  override def visitAsExpression(ctx: AsExpressionContext): Expression = {
    val equalityExpression: Expression = visitEqualityExpression(ctx.equalityExpression())
    val types = ctx.nullablePrimitiveType().asScala.map(visitNullablePrimitiveType).toList
    types.foldLeft(equalityExpression)(
      (e, as) => AsExpression(e, as)
    )
  }

  override def visitNullablePrimitiveType(ctx: NullablePrimitiveTypeContext): Type = {
    val primitiveType = visitPrimitiveType(ctx.primitiveType())
    val nullable = ctx.NULLABLE() != null
    if (nullable) NullableType(primitiveType) else primitiveType
  }

  override def visitEqualityExpression(ctx: EqualityExpressionContext): Expression = {
    val expressions = ctx.relationalExpression().asScala.map(visitRelationalExpression).toList
    val operators = ctx.equalityOperator().asScala.map(visitEqualityOperator).toList
    operators.zip(expressions.tail).foldLeft(expressions.head)(
      (e, pair) => EqualityExpression(pair._1, e, pair._2)
    )
  }

  override def visitEqualityOperator(ctx: EqualityOperatorContext): Operator = {
    if (null != ctx.EQ()) Equal else NotEqual
  }

  override def visitRelationalExpression(ctx: RelationalExpressionContext): Expression = {
    val expressions = ctx.additiveExpression().asScala.map(visitAdditiveExpression).toList
    val operators = ctx.relationalOperator().asScala.map(visitRelationalOperator).toList
    operators.zip(expressions.tail).foldLeft(expressions.head)(
      (e, pair) => RelationalExpression(pair._1, e, pair._2)
    )
  }

  override def visitRelationalOperator(ctx: RelationalOperatorContext): Operator = {
    if (null != ctx.LT()) LessThan
    else if (null != ctx.GT()) GreaterThan
    else if (null != ctx.LE()) LessOrEqual
    else if (null != ctx.GE()) GreaterOrEqual
    else ???
  }

  override def visitAdditiveExpression(ctx: AdditiveExpressionContext): Expression = {
    val expressions: List[Expression] = ctx.multiplicativeExpression().asScala.map(visitMultiplicativeExpression).toList
    val operators: List[Operator] = ctx.additiveOperator().asScala.map(visitAdditiveOperator).toList
    operators.zip(expressions.tail).foldLeft(expressions.head)(
      (e, pair) => AdditiveExpression(pair._1, e, pair._2)
    )
  }

  override def visitAdditiveOperator(ctx: AdditiveOperatorContext): Operator = {
    if (null != ctx.PLUS()) Plus
    else if (null != ctx.MINUS()) Minus
    else if (null != ctx.AMP()) Ampersand
    else ???
  }

  override def visitMultiplicativeExpression(ctx: MultiplicativeExpressionContext): Expression = {
    val expressions = ctx.metaExpression().asScala.map(visitMetaExpression).toList
    val operators = ctx.multiplicativeOperator().asScala.map(visitMultiplicativeOperator).toList
    operators.zip(expressions.tail).foldLeft(expressions.head)(
      (e, pair) => MultiplicativeExpression(pair._1, e, pair._2)
    )
  }

  override def visitMultiplicativeOperator(ctx: MultiplicativeOperatorContext): Operator = {
    if (null != ctx.STAR()) Times
    else if (null != ctx.DIV()) Divide
    else ???
  }

  override def visitMetaExpression(ctx: MetaExpressionContext): Expression = {
    val expressions = ctx.unaryExpression().asScala.map(visitUnaryExpression).toList
    if (autoReduce)
      expressions.head
    else
      expressions.reduce((e1, e2) => MetaExpression(e1, e2))
  }

  override def visitUnaryExpression(ctx: UnaryExpressionContext): Expression = {
    val expression = ctx.typeExpression() match {
      case null => visitUnaryExpression(ctx.unaryExpression())
      case _ => visitTypeExpression(ctx.typeExpression())
    }
    ctx.unaryOperator() match {
      case null => expression
      case o =>
        val operator = visitUnaryOperator(o)
        UnaryExpression(operator, expression)
    }
  }

  override def visitUnaryOperator(ctx: UnaryOperatorContext): Operator = {
    if (null != ctx.PLUS()) Plus
    else if (null != ctx.MINUS()) Minus
    else if (null != ctx.NOT()) Not
    else ???
  }

  override def visitTypeExpression(ctx: TypeExpressionContext): Expression = {
    ctx.TYPE() match {
      case null => visit(ctx.primaryExpression()).asInstanceOf[Expression]
      case _ =>
        val t: Type = visitPrimaryType(ctx.primaryType())
        TypeExpression(t)
    }
  }

  override def visitFieldSelectionOrProjection(ctx: FieldSelectionOrProjectionContext): Node = {
    if (null != ctx.TEXT_LITERAL() || null != ctx.NUMBER_LITERAL()) {
      val literal = if (null == ctx.NUMBER_LITERAL()) readTextLiteral(ctx.TEXT_LITERAL()) else readNumberLiteral(ctx.NUMBER_LITERAL())
      val fieldSelector = visit(ctx.fieldAccessExpression_LITERAL()).asInstanceOf[FieldSelector]
      val literalExpression = if (autoReduce) literal else LiteralExpression(literal)
      FieldSelection(literalExpression, fieldSelector)
    } else if (null != ctx.OPEN_BRACE()) {
      visit(ctx.fieldAccessExpression_OPEN_BRACE())
    } else if (null != ctx.IDENTIFIER()) {
      val identifier = readIdentifier(ctx.IDENTIFIER())
      this.setValue(ctx.fieldAccessExpression_IDENTIFIER, IdentifierExpression(identifier))
      visit(ctx.fieldAccessExpression_IDENTIFIER())
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

  private def setValue(node: ParseTree, value: Node): Unit = values.put(node, value)

  private def readTextLiteral(node: TerminalNode): TextLiteral =
    TextLiteral(unquote(node.getSymbol.getText))

  private def readNumberLiteral(node: TerminalNode): NumberLiteral =
    NumberLiteral(node.getSymbol.getText)

  override def visitFieldAccessExpression_LITERAL(ctx: FieldAccessExpression_LITERALContext): Node = {
    visit(ctx.fieldAccessExpression_primaryExpression())
  }

  override def visitFieldAccessExpression_OPEN_BRACE(ctx: FieldAccessExpression_OPEN_BRACEContext): FieldSelection = {
    val list: ItemList = visitItemList(ctx.itemList())
    val expression: Expression = if (this.autoReduce) list else ListExpression(list)
    val selection: FieldSelector = visit(ctx.fieldAccessExpression_primaryExpression()).asInstanceOf[FieldSelector]
    FieldSelection(expression, selection)
  }

  override def visitItemList(ctx: ItemListContext): ItemList = {
    val items: List[Expression] = ctx.item().asScala.map(visit).map(x => x.asInstanceOf[Expression]).toList
    ItemList(items)
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

  override def visitOptionalFieldSelector(ctx: OptionalFieldSelectorContext): OptionalFieldSelector = {
    val fieldName: Identifier = visitFieldName(ctx.fieldName())
    OptionalFieldSelector(fieldName)
  }

  override def visitProjection(ctx: ProjectionContext): Projection = {
    val selectorList: SelectorList = visitRequiredSelectorList(ctx.requiredSelectorList())
    ctx.QUESTION() match {
      case null => RequiredProjection(selectorList)
      case _ => OptionalProjection(selectorList)
    }
  }

  override def visitRequiredSelectorList(ctx: RequiredSelectorListContext): SelectorList = {
    val requiredFieldSelectors = ctx.requiredFieldSelector().asScala.map(visitRequiredFieldSelector).toList
    SelectorList(requiredFieldSelectors)
  }

  override def visitRequiredFieldSelector(ctx: RequiredFieldSelectorContext): RequiredFieldSelector = {
    val fieldName: Identifier = visitFieldName(ctx.fieldName())
    RequiredFieldSelector(fieldName)
  }

  override def visitFieldAccessExpression_primaryExpression_invokeExpression(ctx: FieldAccessExpression_primaryExpression_invokeExpressionContext): Node = ???

  override def visitFieldAccessExpression_primaryExpression_itemAccessExpression(ctx: FieldAccessExpression_primaryExpression_itemAccessExpressionContext): Node = {
    val itemSelector: Expression = visitItemSelector(ctx.itemSelector())
    val expression: Expression = getValue(ctx.parent).asInstanceOf[Expression]
    val itemAccessExpression: ItemSelectionBase =
      ctx.QUESTION() match {
        case null => ItemSelection(expression, itemSelector)
        case _ => OptionalItemSelection(expression, itemSelector)
      }

    val fieldSelector = visit(ctx.fieldAccessExpression_primaryExpression()).asInstanceOf[FieldSelector]
    FieldSelection(itemAccessExpression, fieldSelector)
  }

  private def getValue(node: ParseTree): Node = values.get(node)

  override def visitItemSelector(ctx: ItemSelectorContext): Expression = {
    visit(ctx.expression()).asInstanceOf[Expression]
  }

  override def visitRecordExpression_fieldAccess(ctx: RecordExpression_fieldAccessContext): Node = ???

  override def visitImplicitTargetFieldSelection(ctx: ImplicitTargetFieldSelectionContext): ImplicitTargetFieldSelection = {
    val fieldName: Identifier = visitFieldName(ctx.fieldName())
    val fieldSelector: FieldSelector = ctx.QUESTION() match {
      case null => RequiredFieldSelector(fieldName)
      case _ => OptionalFieldSelector(fieldName)
    }
    ImplicitTargetFieldSelection(fieldSelector)
  }

  override def visitIntrinsicFunctionExpression(ctx: IntrinsicFunctionExpressionContext): Node = {
    if (null != ctx.HASH_TABLE())
      IdentifierExpression(Identifier("#table"))
    else
      ???
  }

  override def visitEachExpression(ctx: EachExpressionContext): EachExpression = {
    val functionBody: Expression = visit(ctx.eachExpressionBody()).asInstanceOf[Expression]
    EachExpression(functionBody)
  }

  override def visitFunctionExpression(ctx: FunctionExpressionContext): Node = {
    val parameterList = visitParameterList(ctx.parameterList())
    val returnType: Option[Expression] = ctx.returnType() match {
      case null => None
      case t => Some(visitReturnType(t))
    }
    val functionBody: Expression = visit(ctx.functionBody()).asInstanceOf[Expression]
    FunctionExpression(parameterList, returnType, functionBody)
  }

  override def visitReturnType(ctx: ReturnTypeContext): Expression = {
    visitAssertion(ctx.assertion())
  }

  override def visitAssertion(ctx: AssertionContext): Expression = {
    visitType(ctx.`type`())
  }

  override def visitType(ctx: TypeContext): Expression = {
    if (null != ctx.primaryType())
      visitPrimaryType(ctx.primaryType())
    else
      visitExpression(ctx.expression())
  }

  override def visitPrimaryType(ctx: PrimaryTypeContext): Type = {
    super.visitPrimaryType(ctx).asInstanceOf[Type]
  }

  override def visitParameterList(ctx: ParameterListContext): ParameterList = {
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
    val parameterType: Option[Expression] = ctx.parameterType() match {
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

  override def visitParameterType(ctx: ParameterTypeContext): Expression = {
    visitAssertion(ctx.assertion())
  }

  override def visitTableType(ctx: TableTypeContext): TableType = {
    val rowType = visitRowType(ctx.rowType())
    TableType(rowType)
  }

  override def visitRowType(ctx: RowTypeContext): FieldSpecificationList = {
    this.visitFieldSpecificationList(ctx.fieldSpecificationList())
  }

  override def visitFieldSpecificationList(ctx: FieldSpecificationListContext): FieldSpecificationList = {
    val fieldSpecs = ctx.fieldSpecification().asScala.map(visitFieldSpecification).toList
    FieldSpecificationList(fieldSpecs)
  }

  override def visitFieldSpecification(ctx: FieldSpecificationContext): FieldSpecification = {
    val identifier = readOptionalIdentifier(ctx.IDENTIFIER()).getOrElse(
      readGeneralizedIdentifier(ctx.GENERALIZED_IDENTIFIER())
    )
    val optional = ctx.OPTIONAL() != null
    val fieldType = this.visitFieldTypeSpecification(ctx.fieldTypeSpecification())
    FieldSpecification(optional, identifier, fieldType)
  }

  override def visitFieldTypeSpecification(ctx: FieldTypeSpecificationContext): Expression =
    visitFieldType(ctx.fieldType())

  override def visitFieldType(ctx: FieldTypeContext): Expression = {
    if (null != ctx.IDENTIFIER())
      readIdentifier(ctx.IDENTIFIER())
    else
      visitType(ctx.`type`())
  }

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
      (() => null != ctx.TABLE()) -> TablePrimitiveType,
      (() => null != ctx.TEXT()) -> TextType,
      (() => null != ctx.TYPE()) -> TypeType
    )

    cond.find(_._1()).map(_._2).getOrElse(???)
  }
}
