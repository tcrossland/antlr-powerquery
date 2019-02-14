package io.truedat.ast

import io.truedat.eval._
import io.truedat.reduce._

sealed abstract class Node
sealed abstract class Expression extends Node with ExpressionReducer

case class Section(name: Option[Identifier], members: List[SectionMember], attributes: Option[RecordLiteral]) extends Expression with SectionReducer
case class SectionMember(name: Identifier, expression: Expression, shared: Boolean, attributes: Option[RecordLiteral]) extends Expression with SectionMemberReducer
case class LogicalOrExpression(e1: Expression, e2: Expression) extends Expression with LogicalOrExpressionReducer
case class LogicalAndExpression(e1: Expression, e2: Expression) extends Expression with LogicalAndExpressionReducer
case class IsExpression(expression: Expression, is: Type) extends Expression with IsExpressionReducer
case class AsExpression(expression: Expression, as: Type) extends Expression with AsExpressionReducer
case class EqualityExpression(op: Operator, e1: Expression, e2: Expression) extends Expression with EqualityExpressionReducer
case class RelationalExpression(op: Operator, e1: Expression, e2: Expression) extends Expression with RelationalExpressionReducer
case class AdditiveExpression(op: Operator, e1: Expression, e2: Expression) extends Expression with AdditiveExpressionReducer with AdditiveExpressionEvaluator
case class MultiplicativeExpression(op: Operator, e1: Expression, e2: Expression) extends Expression with MultiplicativeExpressionReducer
case class MetaExpression(expression: Expression, meta: Expression) extends Expression
case class UnaryExpression(operator: Operator, expression: Expression) extends Expression with UnaryExpressionReducer
case class Identifier(id: String) extends Expression
case class IdentifierExpression(identifier: Identifier) extends Expression with IdentifierExpressionReducer
case class SectionAccessExpression(section: Identifier, identifier: Identifier) extends Expression

sealed abstract class ItemSelectionBase extends Expression
case class ItemSelection(expression: Expression, itemSelector: Expression) extends ItemSelectionBase with ItemSelectionReducer
case class OptionalItemSelection(expression: Expression, itemSelector: Expression) extends ItemSelectionBase with OptionalItemSelectionReducer

case class InvokeExpression(expression: Expression, argumentList: ArgumentList) extends Expression with InvokeExpressionReducer with InvokeExpressionEvaluator
case class RecordExpression(fieldList: FieldList) extends Expression with RecordExpressionReducer with RecordExpressionEvaluator
case class LetExpression(variableList: VariableList, expression: Expression) extends Expression with LetExpressionReducer
case class ArgumentList(expressions: List[Expression]) extends Expression with ArgumentListReducer
case class VariableList(variables: List[Variable]) extends Expression with VariableListReducer
case class Variable(name: Identifier, expression: Expression) extends Expression with VariableReducer
case class TypeExpression(t: Type) extends Expression with TypeExpressionReducer
case class Field(fieldName: Identifier, expression: Expression) extends Expression with FieldReducer
case class FieldList(fields: List[Field]) extends Expression with FieldListReducer
case class TableType(rowType: FieldSpecificationList) extends Type
case class FieldSpecificationList(fieldSpecs: List[FieldSpecification]) extends Expression
case class FieldSpecification(optional: Boolean, identifier: Identifier, fieldType: Expression) extends Node

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
case class FunctionExpression(parameterList: ParameterList, returnType: Option[Expression], functionBody: Expression) extends Expression with FunctionExpressionReducer with FunctionExpressionEvaluator
case class ParameterList(fixedParameters: Option[FixedParameterList], optionalParameters: Option[OptionalParameterList]) extends Expression with ParameterListReducer
case class FixedParameterList(parameters: List[Parameter]) extends Expression with FixedParameterListReducer
case class OptionalParameterList(parameters: List[Parameter]) extends Expression with OptionalParameterListReducer
case class Parameter(identifier: Identifier, parameterType: Option[Expression]) extends Expression with ParameterReducer

sealed abstract class Type extends Expression with TypeReducer

case class NullableType(t: Type) extends Type
case class LiteralExpression(literal: Value) extends Expression
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

sealed abstract class Value extends Expression with ValueReducer

case object NullLiteral extends Value {
  override def toString: String = "null"
}

sealed abstract class LogicalLiteral extends Value

case object FalseLiteral extends LogicalLiteral {
  override def toString: String = "false"
}

case object TrueLiteral extends LogicalLiteral {
  override def toString: String = "true"
}

case class RecordLiteral(value: List[LiteralField] = List.empty) extends Value {
  override def toString: String = value.mkString("[", ", ", "]")
}

case class LiteralField(name: Identifier, value: Value) extends Value {
  override def toString: String = name.id + " = " + value.toString
}

case class ListLiteral(value: List[Value] = List.empty) extends Value {
  override def toString: String = value.mkString("{", ", ", "}")
}

case class NumberLiteral(value: String) extends Value {
  override def toString: String = value
}

case class TextLiteral(value: String) extends Value {
  override def toString: String = value
}

case class ItemList(list: List[Expression]) extends Expression with ItemListReducer {
  override def toString: String = list.mkString("{", ", ", "}")
}

case class Sequence(from: Expression, to: Expression) extends Expression {
  override def toString: String = from.toString + " .. " + to.toString
}

sealed abstract class LineageElement extends Value

abstract class LibraryFunction extends LineageElement with ValueReducer {
  def args: List[Expression]
  def functionName: String = this.getClass.getSimpleName.replace("$u002E", ".")
  override def toString: String = args.head.toString + " |> " + this.functionName
}

sealed abstract class Builtin extends Value {
  override def toString: String = this.getClass.getSimpleName.replace("$u002E", ".")
}

case object `BinaryEncoding.Base64` extends Builtin
case object `BinaryEncoding.Hex` extends Builtin
case object `BinaryOccurrence.Optional` extends Builtin
case object `BinaryOccurrence.Repeating` extends Builtin
case object `BinaryOccurrence.Required` extends Builtin
case object `ByteOrder.BigEndian` extends Builtin
case object `ByteOrder.LittleEndian` extends Builtin
case object `Compression.Deflate` extends Builtin
case object `Compression.GZip` extends Builtin
case object `Day.Sunday` extends Builtin
case object `Day.Monday` extends Builtin
case object `Day.Tuesday` extends Builtin
case object `Day.Wednesday` extends Builtin
case object `Day.Thursday` extends Builtin
case object `Day.Friday` extends Builtin
case object `Day.Saturday` extends Builtin
case object `GroupKind.Global` extends Builtin
case object `GroupKind.Local` extends Builtin
case object `Int64.Type` extends Builtin
case object `JoinAlgorithm.Dynamic` extends Builtin
case object `JoinAlgorithm.LeftHash` extends Builtin
case object `JoinAlgorithm.LeftIndex` extends Builtin
case object `JoinAlgorithm.PairwiseHash` extends Builtin
case object `JoinAlgorithm.RightHash` extends Builtin
case object `JoinAlgorithm.RightIndex` extends Builtin
case object `JoinAlgorithm.SortMerge` extends Builtin
case object `JoinKind.FullOuter` extends Builtin
case object `JoinKind.Inner` extends Builtin
case object `JoinKind.LeftAnti` extends Builtin
case object `JoinKind.LeftOuter` extends Builtin
case object `JoinKind.RightAnti` extends Builtin
case object `JoinKind.RightOuter` extends Builtin
case object `JoinSide.Left` extends Builtin
case object `JoinSide.Right` extends Builtin
case object `MissingField.Error` extends Builtin
case object `MissingField.Ignore` extends Builtin
case object `MissingField.UseNull` extends Builtin
case object `Occurrence.All` extends Builtin
case object `Occurrence.First` extends Builtin
case object `Occurrence.Last` extends Builtin
case object `Occurrence.Optional` extends Builtin
case object `Occurrence.Repeating` extends Builtin
case object `Occurrence.Required` extends Builtin
case object `Order.Ascending` extends Builtin
case object `Order.Descending` extends Builtin
case object `QuoteStyle.Csv` extends Builtin
case object `QuoteStyle.None` extends Builtin
case object `RelativePosition.FromEnd` extends Builtin
case object `RelativePosition.FromStart` extends Builtin
case object `Replacer.ReplaceText` extends Builtin
case object `Replacer.ReplaceValue` extends Builtin
case object `RoundingMode.AwayFromZero` extends Builtin
case object `RoundingMode.Down` extends Builtin
case object `RoundingMode.ToEven` extends Builtin
case object `RoundingMode.TowardZero` extends Builtin
case object `RoundingMode.Up` extends Builtin
case object `TextEncoding.Ascii` extends Builtin
case object `TextEncoding.BigEndianUnicode` extends Builtin
case object `TextEncoding.Unicode` extends Builtin
case object `TextEncoding.Utf16` extends Builtin
case object `TextEncoding.Utf8` extends Builtin
case object `TextEncoding.Windows` extends Builtin
case object `TraceLevel.Critical` extends Builtin
case object `TraceLevel.Error` extends Builtin
case object `TraceLevel.Information` extends Builtin
case object `TraceLevel.Verbose` extends Builtin
case object `TraceLevel.Warning` extends Builtin
