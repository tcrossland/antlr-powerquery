package io.truedat.ast

import io.truedat.eval._
import io.truedat.reduce._

sealed abstract class Node

sealed abstract class TypeNode extends Node

case class Section(name: Option[Identifier], members: List[SectionMember], attributes: Option[RecordLiteral]) extends Expression with SectionReducer

sealed abstract class Expression extends Node with ExpressionReducer

abstract class TestExpression extends Expression

case class SectionMember(name: Identifier, expression: Expression, shared: Boolean, attributes: Option[RecordLiteral]) extends Expression with SectionMemberReducer

case class LogicalOrExpression(e1: Expression, e2: Expression) extends Expression with LogicalOrExpressionReducer

case class LogicalAndExpression(e1: Expression, e2: Expression) extends Expression with LogicalAndExpressionReducer

case class IsExpression(expression: Expression, is: Type) extends Expression

case class AsExpression(expression: Expression, as: Type) extends Expression

case class EqualityExpression(op: Operator, e1: Expression, e2: Expression) extends Expression with EqualityExpressionReducer

case class RelationalExpression(op: Operator, e1: Expression, e2: Expression) extends Expression with RelationalExpressionReducer

case class AdditiveExpression(op: Operator, e1: Expression, e2: Expression) extends Expression with AdditiveExpressionReducer with AdditiveExpressionEvaluator

case class MultiplicativeExpression(op: Operator, e1: Expression, e2: Expression) extends Expression with MultiplicativeExpressionReducer

case class MetaExpression(expression: Expression, meta: Expression) extends Expression

case class UnaryExpression(operator: Operator, expression: Expression) extends Expression

case class Identifier(id: String) extends Expression

case class IdentifierExpression(identifier: Identifier) extends Expression with IdentifierExpressionReducer

case class SectionAccessExpression(section: Identifier, identifier: Identifier) extends Expression

sealed abstract class ItemSelectionBase extends Expression

case class ItemSelection(expression: Expression, itemSelector: Expression) extends ItemSelectionBase with ItemSelectionReducer with ItemSelectionEvaluator

case class OptionalItemSelection(expression: Expression, itemSelector: Expression) extends ItemSelectionBase

case class InvokeExpression(expression: Expression, argumentList: ArgumentList) extends Expression with InvokeExpressionReducer with InvokeExpressionEvaluator

case class RecordExpression(fieldList: FieldList) extends Expression

case class LetExpression(variableList: VariableList, expression: Expression) extends Expression with LetExpressionReducer

case class ArgumentList(expressions: List[Expression]) extends Expression with ArgumentListReducer {
  // override def toString: String = "Argument" + expressions.toString
}

case class VariableList(variables: List[Variable]) extends Expression with VariableListReducer {
  // override def toString: String = "Variable" + variables.toString
}

case class Variable(name: Identifier, expression: Expression) extends Expression with VariableReducer

case class TypeExpression(t: Type) extends Expression with TypeExpressionReducer

case class Field(fieldName: Identifier, expression: Expression) extends Expression

case class FieldList(fields: List[Field]) extends Expression {
  override def toString: String = "Field" + fields.toString
}

case class TableType(rowType: FieldSpecificationList) extends Type
// case class RowType(fieldSpecs: FieldSpecificationList) extends Node

case class FieldSpecificationList(fieldSpecs: List[FieldSpecification]) extends Expression

case class FieldSpecification(optional: Boolean, identifier: Identifier, fieldType: Expression) extends Node

case class FieldType(t: Identifier) extends Node

sealed abstract class FieldSelector extends Expression

case class RequiredFieldSelector(name: Identifier) extends FieldSelector with FieldSelectorReducer

case class OptionalFieldSelector(name: Identifier) extends FieldSelector with FieldSelectorReducer

case class FieldSelection(expression: Expression, selection: FieldSelector) extends Expression with FieldSelectionReducer with FieldSelectionEvaluator

case class ImplicitTargetFieldSelection(selection: FieldSelector) extends Expression with ImplicitTargetFieldSelectionReducer

sealed abstract class Projection extends FieldSelector

case class RequiredProjection(selectors: SelectorList) extends Projection

case class OptionalProjection(selectors: SelectorList) extends Projection

case class SelectorList(selectors: List[FieldSelector]) extends Node

case class ListExpression(list: ItemList) extends Expression with ListExpressionReducer

case class EachExpression(functionBody: Expression) extends Expression with EachExpressionReducer

case class FunctionExpression(parameterList: ParameterList, returnType: Option[Expression], functionBody: Expression) extends Expression with FunctionExpressionReducer

case class ParameterList(fixedParameters: Option[FixedParameterList], optionalParameters: Option[OptionalParameterList]) extends Expression

case class FixedParameterList(parameters: List[Parameter]) extends Expression

case class OptionalParameterList(parameters: List[Parameter]) extends Expression

case class Parameter(identifier: Identifier, parameterType: Option[Expression]) extends Expression with ParameterReducer

sealed abstract class Type extends Expression with TypeReducer

case class NullableType(t: Type) extends Type

case class LiteralExpression(literal: Value) extends Expression

sealed abstract class IntrinsicFunction extends Expression with IntrinsicFunctionReducer

case object IntrinsicTableFunction extends IntrinsicFunction
case object DateTimeLocalNow extends IntrinsicFunction

case object AnyType extends Type

case object AnyNonNullType extends Type

case object BinaryType extends Type

case object DateType extends Type

case object DateTimeType extends Type

case object DateTimeZoneType extends Type

case object DurationType extends Type

case object FunctionType extends Type

case object ListType extends Type

case object LogicalType extends Type

case object NoneType extends Type

case object NullType extends Type

case object NumberType extends Type

case object RecordType extends Type

case object TablePrimitiveType extends Type

case object TextType extends Type

case object TypeType extends Type

sealed abstract class Operator extends Node

case object Equal extends Operator

case object NotEqual extends Operator

case object LessThan extends Operator

case object GreaterThan extends Operator

case object LessOrEqual extends Operator

case object GreaterOrEqual extends Operator

case object Plus extends Operator

case object Minus extends Operator

case object Times extends Operator

case object Divide extends Operator

case object Ampersand extends Operator

case object Not extends Operator

sealed abstract class Value extends Expression with ValueReducer // TODO: should extend Node not Expression?

case object NullLiteral extends Value

sealed abstract class LogicalLiteral extends Value

case object FalseLiteral extends LogicalLiteral

case object TrueLiteral extends LogicalLiteral

case class RecordLiteral(value: List[LiteralField]) extends Value

case class LiteralField(name: Identifier, value: Value) extends Value

case class ListLiteral(value: List[Value]) extends Value {
  override def toString: String = "Literal" + value.toString
}

case class NumberLiteral(value: String) extends Value

case class TextLiteral(value: String) extends Value {
  override def toString: String = value
}

case class ItemList(list: List[Expression]) extends Expression with ItemListReducer

case class Sequence(from: Expression, to: Expression) extends Node

sealed abstract class LineageElement extends Value

case class DataSource(id: String, args: Any) extends LineageElement with DataSourceEvaluator

case class DataStructure(schema: String, item: String, source: DataSource) extends LineageElement

case class Transformation(transform: String, e: Expression, args: Any) extends LineageElement with ValueReducer

case class Function(id: String, args: Any = None) extends LineageElement