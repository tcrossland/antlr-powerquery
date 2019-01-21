parser grammar PowerQueryFormulaParser;

options { tokenVocab=PowerQueryFormulaLexer; }

// Section Documents

section_document: section;

section
	: literal_attributes? SECTION section_name? SEMICOLON section_member*;

section_name: IDENTIFIER;

section_member
	: literal_attributes? SHARED? section_member_name EQ expression SEMICOLON;

section_member_name: IDENTIFIER;

// Expression Documents

expression_document: expression;

expression
	: logical_expression
	| each_expression
	| function_expression
	| let_expression
	| if_expression
	| error_raising_expression
	| error_handling_expression
	;

// Logical Expressions

logical_expression
	: logical_or_expression
	| logical_and_expression
	;

logical_or_expression
	: logical_and_expression (OR logical_and_expression)*
	;

logical_and_expression
	: is_expression (AND is_expression)*
	;

// Is expression

is_expression
	: as_expression (IS nullable_primitive_type)*
	;

nullable_primitive_type
	: NULLABLE? primitive_type
	;

// As expression

as_expression // A1
	: equality_expression as_nullable_primitive_type?
	;

as_nullable_primitive_type
	: AS nullable_primitive_type
	;

// Equality expression

equality_expression // A2
	: relational_expression op_equality_expression?
	;

op_equality_expression
	: (EQ | NE) equality_expression
	;

relational_expression // A3
	: additive_expression op_relational_expression?
	;

op_relational_expression
	: (LT | GT | LE | GE) relational_expression
	;

additive_expression // A4
	: multiplicative_expression op_additive_expression?
	;

op_additive_expression
	: (PLUS | MINUS | AMP) additive_expression
	;

multiplicative_expression // A5
	: metadata_expression op_multiplicative_expression?
	;

op_multiplicative_expression
	: (STAR | DIV) multiplicative_expression
	;

metadata_expression // A6
	: unary_expression meta_unary_expression?
	;

meta_unary_expression
	: META unary_expression
	;

unary_expression
	: type_expression
	| PLUS unary_expression
	| MINUS unary_expression
	| NOT unary_expression
	;

primary_expression
	: any_literal #literal_expression
	| OPEN_BRACE item_list? CLOSE_BRACE #list_expression
	| OPEN_BRACKET field_list? CLOSE_BRACKET #primary_expression_record_expression
	| IDENTIFIER #identifier_expression
	| AT IDENTIFIER #identifier_expression
	| IDENTIFIER BANG IDENTIFIER #section_access_expression
	| OPEN_PARENS expression CLOSE_PARENS #parenthesized_expression
	| field_access_expression_ #primary_expression_field_access_expression
	| primary_expression OPEN_BRACE item_selector CLOSE_BRACE QUESTION? #primary_expression_item_access_expression
	| primary_expression OPEN_PARENS argument_list? CLOSE_PARENS #primary_expression_invoke_expression
	| DOT_DOT_DOT #not_implemented_expression
	| builtin_function_expression #primary_expression_table_builtin
	;

builtin_function_expression
	: HASH_TABLE
	;

invoke_expression
	: primary_expression OPEN_PARENS argument_list? CLOSE_PARENS
	;
/*
primary_expression_
	: OPEN_BRACE primary_expression_OPEN_BRACE
	| OPEN_BRACE primary_expression_OPEN_BRACKET
	| IDENTIFIER primary_expression_IDENTIFIER
	| AT primary_expression_AT
	| OPEN_PARENS primary_expression_OPEN_PARENS
	| DOT_DOT_DOT primary_expression_DOT_DOT_DOT
	// field_access_expression_
	// any_literal
	;
primary_expression_any_literal
	: // epsilon
	;
primary_expression_OPEN_BRACE: item_list? CLOSE_BRACE;
primary_expression_OPEN_BRACKET: field_list? CLOSE_BRACKET;
primary_expression_IDENTIFIER
	: // epsilon
	| BANG IDENTIFIER;
primary_expression_AT: IDENTIFIER;
primary_expression_OPEN_PARENS: expression CLOSE_PARENS;
primary_expression_field_access_expression_
	: // epsilon
	;
primary_expression_primary_expression
	: OPEN_BRACE item_selector CLOSE_BRACE QUESTION?
	| OPEN_PARENS argument_list? CLOSE_PARENS;
primary_expression_DOT_DOT_DOT
	: // epsilon
	;
 */

field_access_expression_
	: (TEXT_LITERAL | NUMBER_LITERAL) field_access_expression_LITERAL
	| OPEN_BRACE field_access_expression_OPEN_BRACE
	| OPEN_BRACKET field_access_expression_OPEN_BRACKET
	| IDENTIFIER field_access_expression_IDENTIFIER
	| AT field_access_expression_AT
	| OPEN_PARENS field_access_expression_OPEN_PARENS
	| DOT_DOT_DOT field_access_expression_DOT_DOT_DOT
	;

field_access_expression_primary_expression
	: field_selector #field_access_expression_primary_expression_field_selection
	| OPEN_BRACKET required_selector_list CLOSE_BRACKET QUESTION? #field_access_expression_primary_expression_projection
	| OPEN_BRACE item_selector CLOSE_BRACE QUESTION? field_access_expression_primary_expression  #field_access_expression_primary_expression_item_access_expression
	| OPEN_PARENS argument_list? CLOSE_PARENS field_access_expression_primary_expression #field_access_expression_primary_expression_invoke_expression
	;

field_access_expression_field_selector: /* epsilon */;
// X: [primary_expression, field_selector]
field_access_expression_LITERAL: field_access_expression_primary_expression;
field_access_expression_OPEN_BRACE: item_list? CLOSE_BRACE field_access_expression_primary_expression;
field_access_expression_OPEN_BRACKET
	: field_list CLOSE_BRACKET field_access_expression_primary_expression
	| field_name CLOSE_BRACKET field_access_expression_required_field_selector
	| field_name CLOSE_BRACKET QUESTION field_access_expression_optional_field_selector
	;
field_access_expression_IDENTIFIER
	: field_access_expression_primary_expression
	| BANG IDENTIFIER field_access_expression_primary_expression
	;
field_access_expression_AT: IDENTIFIER field_access_expression_primary_expression;
field_access_expression_OPEN_PARENS: expression CLOSE_PARENS field_access_expression_primary_expression;
field_access_expression_field_access_expression: field_access_expression_primary_expression;
field_access_expression_DOT_DOT_DOT: field_access_expression_primary_expression;
// corners: [field_selector, field_access_expression, required_field_selector, optional_field_selector]
field_access_expression_required_field_selector: field_access_expression_field_selector;
field_access_expression_optional_field_selector: field_access_expression_field_selector;
// corners: [required_field_selector, optional_field_selector]

argument_list
	: expression (COMMA expression)*
	;

item_list
	: item (COMMA item)*
	;

item
	: expression
	| expression DOT_DOT expression
	;

field_list
	: field (COMMA field)*
	;

field: field_name EQ expression;

field_name: GENERALIZED_IDENTIFIER | IDENTIFIER;

item_selector: expression;

field_selector
	: required_field_selector
	| optional_field_selector
	;

required_field_selector: OPEN_BRACKET field_name CLOSE_BRACKET;
optional_field_selector: OPEN_BRACKET field_name CLOSE_BRACKET QUESTION;

required_selector_list
	: required_field_selector (COMMA required_field_selector)*
	;

function_expression
	: OPEN_PARENS parameter_list? CLOSE_PARENS return_type? ARROW function_body;
function_body: expression;
parameter_list
	: fixed_parameter_list (COMMA optional_parameter_list)?
	| optional_parameter_list
	;
fixed_parameter_list
	: parameter (COMMA parameter)*
	;
parameter
	: parameter_name parameter_type?
	;
parameter_name
	: IDENTIFIER
	;
parameter_type
	: assertion
	;
return_type
	: assertion
	;
assertion
	: AS type
	;
optional_parameter_list
	: optional_parameter (COMMA optional_parameter)*
	;
optional_parameter
	: OPTIONAL parameter
	;
each_expression
	: EACH each_expression_body
	;
each_expression_body: function_body;
let_expression
	: LET variable_list IN expression
	;
variable_list
	: variable (COMMA variable)*
	;
variable: variable_name EQ expression;
variable_name: GENERALIZED_IDENTIFIER | IDENTIFIER;

if_expression
	: IF if_condition THEN true_expression ELSE false_expression
	;
if_condition: expression;
true_expression: expression;
false_expression: expression;

type_expression
	: TYPE primary_type
	| primary_expression
	;
type
	: OPEN_PARENS expression CLOSE_PARENS
	| primary_type
	;
primary_type
	: table_type
	| primitive_type
	| record_type
	| list_type
	| function_type
	| nullable_type
	;
primitive_type
	: ANY
	| ANYNONNULL
	| BINARY
	| DATE
	| DATETIME
	| DATETIMEZONE
	| DURATION
	| FUNCTION
	| LIST
	| LOGICAL
	| NONE
	| NULL
	| NUMBER
	| RECORD
	| TABLE
	| TEXT
	| TYPE
	;
record_type
	: OPEN_BRACKET open_record_marker CLOSE_BRACKET
	| OPEN_BRACKET field_specification_list CLOSE_BRACKET
	| OPEN_BRACKET field_specification_list COMMA open_record_marker CLOSE_BRACKET
	;
field_specification_list
	: field_specification (COMMA field_specification)*
	;
field_specification
	: IDENTIFIER field_type_specification?
	| GENERALIZED_IDENTIFIER field_type_specification?
	| OPTIONAL IDENTIFIER field_type_specification?
	| OPTIONAL GENERALIZED_IDENTIFIER field_type_specification?
	;
field_type_specification
	: EQ field_type
	;
field_type
	: type
	| IDENTIFIER;
open_record_marker: DOT_DOT_DOT;
list_type: OPEN_BRACE item_type CLOSE_BRACE;
item_type: type;
function_type: FUNCTION OPEN_PARENS parameter_specification_list? CLOSE_PARENS return_type;
parameter_specification_list
	: required_parameter_specification_list
	| required_parameter_specification_list COMMA optional_parameter_specification_list
	| optional_parameter_specification_list
	;
required_parameter_specification_list
	: parameter_specification
	;
optional_parameter_specification_list
	: optional_parameter_specification
	| optional_parameter_specification COMMA optional_parameter_specification_list
	;
optional_parameter_specification
	: OPTIONAL parameter_specification
	;
parameter_specification
	: parameter_name parameter_type
	;
table_type
	: TABLE row_type
	;
row_type
	: OPEN_BRACKET field_specification_list CLOSE_BRACKET
	;
nullable_type
	: NULLABLE type
	;

error_raising_expression
	: ERROR expression
	;
error_handling_expression
	: TRY protected_expression otherwise_clause?
	;
protected_expression: expression;
otherwise_clause: OTHERWISE default_expression;
default_expression: expression;

literal_attributes: record_literal;
record_literal: OPEN_BRACKET literal_field_list? CLOSE_BRACKET;
literal_field_list
	: literal_field
	| literal_field COMMA literal_field_list;
literal_field
	: field_name EQ any_literal
	;
list_literal
	: OPEN_BRACE literal_item_list CLOSE_BRACE
	;
literal_item_list
	: any_literal COMMA literal_item_list
	;
any_literal
	: record_literal
	| list_literal
	| logical_literal
	| NUMBER_LITERAL
	| TEXT_LITERAL
	| NULL;

logical_literal
	: TRUE
	| FALSE
	;
