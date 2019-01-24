package io.truedat.model.expression

import io.truedat.model.Node
import io.truedat.model.identifier.Identifier
import io.truedat.model.item.ItemList
import io.truedat.model.literal.{ Literal, RecordLiteral }

sealed abstract class TypeNode extends Node

sealed abstract class Expression extends Node

case class LogicalOrExpression(e1: Expression, e2: Expression) extends Expression

case class LogicalAndExpression(e1: Expression, e2: Expression) extends Expression

case class IsExpression(expression: Expression, is: Type) extends Expression

case class AsExpression(expression: Expression, as: Type) extends Expression

case class EqualityExpression(op: Operator, e1: Expression, e2: Expression) extends Expression

case class RelationalExpression(op: Operator, e1: Expression, e2: Expression) extends Expression

case class AdditiveExpression(op: Operator, e1: Expression, e2: Expression) extends Expression

case class MultiplicativeExpression(op: Operator, e1: Expression, e2: Expression) extends Expression

case class MetaExpression(expression: Expression, meta: Expression) extends Expression

case class UnaryExpression(operator: Operator, expression: Expression) extends Expression

case class IdentifierExpression(identifier: Identifier) extends Expression

case class SectionAccessExpression(section: Identifier, identifier: Identifier) extends Expression

sealed abstract class ItemSelectionBase extends Expression

case class ItemSelection(expression: Expression, itemSelector: Expression) extends ItemSelectionBase
case class OptionalItemSelection(expression: Expression, itemSelector: Expression) extends ItemSelectionBase

case class InvokeExpression(expression: Expression, argumentList: ArgumentList) extends Expression

case class RecordExpression(fieldList: FieldList) extends Expression

case class LetExpression(variableList: Node, expression: Expression) extends Expression

case class ArgumentList(expressions: List[Expression]) extends Node

case class VariableList(variables: List[Variable]) extends Node

case class Variable(name: Identifier, expression: Expression) extends Node

case object TypeExpression extends Expression

case class Field(fieldName: Identifier, expression: Expression) extends Node

case class FieldList(fields: List[Field]) extends Node

case class RowType(fieldSpecs: List[FieldSpecification]) extends Node

case class FieldSpecification(optional: Boolean, identifier: Identifier, fieldType: FieldType) extends Node

case class FieldType(t: Identifier) extends Node

case class SectionMember(name: Identifier, expression: Expression, shared: Boolean, attributes: Option[RecordLiteral]) extends Node

case class Section(name: Option[Identifier], members: List[SectionMember], attributes: Option[RecordLiteral]) extends Node

sealed abstract class FieldSelector extends Node

case class RequiredFieldSelector(name: Identifier) extends FieldSelector

case class OptionalFieldSelector(name: Identifier) extends FieldSelector

case class FieldSelection(expression: Expression, selection: Node) extends Expression

case class ImplicitTargetFieldSelection(selection: Node) extends Expression

sealed abstract class Projection extends Node

case class RequiredProjection(selectors: SelectorList) extends Projection

case class OptionalProjection(selectors: SelectorList) extends Projection

case class SelectorList(selectors: List[Node]) extends Node

case class ListExpression(list: ItemList) extends Expression {
  def value: Any = list.value
}

case class EachExpression(functionBody: Expression) extends Expression

case class FunctionExpression(parameterList: Node, returnType: Option[Type], functionBody: Expression) extends Expression

case class ParameterList(fixedParameters: Option[FixedParameterList], optionalParameters: Option[OptionalParameterList]) extends Node

case class FixedParameterList(parameters: List[Parameter]) extends Node
case class OptionalParameterList(parameters: List[Parameter]) extends Node

case class Parameter(name: Identifier, parameterType: Option[Type]) extends Node

sealed abstract class Type extends Expression

case class NullableType(t: Type) extends Type

case class ExpressionType(expression: Expression) extends Type

case class LiteralExpression(literal: Literal) extends Expression {
  def value: Any = literal.value
}

case object IntrinsicTableFunction extends Expression

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
case object TableType extends Type
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

