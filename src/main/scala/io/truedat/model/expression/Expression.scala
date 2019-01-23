package io.truedat.model.expression

import io.truedat.model.Node
import io.truedat.model.identifier.Identifier
import io.truedat.model.item.ItemList
import io.truedat.model.literal.{ Literal, RecordLiteral }

sealed abstract class TypeNode extends Node

sealed abstract class Expression extends Node

case class LogicalOrExpression(expressions: List[Expression]) extends Expression

case class LogicalAndExpression(expressions: List[Expression]) extends Expression

case class IsExpression(expression: Expression) extends Expression

case class AsExpression(expression: Expression) extends Expression

case class EqualityExpression(expressions: List[Expression]) extends Expression

case class RelationalExpression(expressions: List[Expression]) extends Expression

case class AdditiveExpression(expressions: List[Expression]) extends Expression

case class MultiplicativeExpression(expressions: List[Expression]) extends Expression

case class MetaExpression(expressions: List[Expression]) extends Expression

case class UnaryExpression(expression: Expression) extends Expression

case class IdentifierExpression(identifier: Identifier) extends Expression

case class SectionAccessExpression(section: Identifier, identifier: Identifier) extends Expression

case class ItemSelection(expression: Expression, itemSelector: Expression, optional: Boolean) extends Expression

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

case class FieldSelector(name: Identifier, optional: Boolean = false) extends Node

case class FieldSelection(expression: Expression, selection: Node) extends Expression

case class ImplicitTargetFieldSelection(selection: Node) extends Expression

case class Projection(selectors: SelectorList, optional: Boolean) extends Node

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
