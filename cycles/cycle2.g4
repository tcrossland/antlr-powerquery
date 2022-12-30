parser grammar cycle2;

options { tokenVocab=PowerQueryFormulaLexer; }

expression
	: each_expression
	| function_expression
	| let_expression
	| if_expression
	| error_raising_expression
	| error_handling_expression
	;



primary_expression
	: pe=primary_expression_start
	;

primary_expression_start
    : TEXT_LITERAL | NUMBER_LITERAL                                 // literal_expression
	| OPEN_BRACE item_list? CLOSE_BRACE                             // list_expression
	| OPEN_BRACKET field_list CLOSE_BRACKET                         // record_expression
	| identifier_expression                                         // identifier_expression
	| section_access_expression                                     // section_access_expression
	| OPEN_PARENS expression CLOSE_PARENS                           // parenthesized_expression
	| field_access_expression                                       // field_access_expression
	| item_access_expression                                        // item_access_expression
	| primary_expression OPEN_PARENS argument_list? CLOSE_PARENS    // invoke_expression
	| DOT_DOT_DOT                                                   // not_implemented_expression
    ;

identifier: IDENTIFIER;

identifier_expression: identifier_reference;

identifier_reference
	: exclusive_identifier_reference
	| inclusive_identifier_reference
	;

exclusive_identifier_reference: identifier;

inclusive_identifier_reference: AT identifier;

section_access_expression: identifier BANG identifier;

argument_list
	: expression
	| expression COMMA argument_list
	;

item_list
	: item
	| item COMMA item_list
	;

item
	: expression
	| expression DOT_DOT expression
	;

field_list
	: field
	| field COMMA field_list
	;

field: field_name EQ expression;

field_name: GeneralizedIdentifier;

item_access_expression
	: item_selection
	| optional_item_selection
	;

item_selection: primary_expression OPEN_BRACE item_selector CLOSE_BRACE;
optional_item_selection: primary_expression OPEN_BRACE item_selector CLOSE_BRACE QUESTION;
item_selector: expression;

field_access_expression
	: field_selection
	| implicit_target_field_selection
	| projection
	| implicit_target_projection
	;

field_selection: primary_expression field_selector;

field_selector
	: required_field_selector
	| optional_field_selector
	;

required_field_selector: OPEN_BRACKET field_name CLOSE_BRACKET;
optional_field_selector: OPEN_BRACKET field_name CLOSE_BRACKET QUESTION;
implicit_target_field_selection: field_selector;

projection
	: primary_expression required_projection
	| primary_expression optional_projection
	;

required_projection: OPEN_BRACKET required_selector_list CLOSE_BRACKET;
optional_projection: OPEN_BRACKET required_selector_list CLOSE_BRACKET QUESTION;
required_selector_list
	: required_field_selector
	| required_field_selector COMMA required_selector_list
	;
implicit_target_projection: record_projection;
record_projection
	: field_selector
	| field_selector COMMA record_projection
	;

function_expression
	: OPEN_PARENS parameter_list? CLOSE_PARENS return_type? ARROW function_body;
function_body: expression;
parameter_list
	: fixed_parameter_list
	| fixed_parameter_list COMMA optional_parameter_list
	| optional_parameter_list
	;
fixed_parameter_list
	: parameter
	| parameter COMMA fixed_parameter_list
	;
parameter
	: parameter_name parameter_type?
	;
parameter_name
	: identifier
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
	: optional_parameter
	| optional_parameter COMMA optional_parameter_list
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
	: variable
	| variable COMMA variable_list
	;
variable: variable_name EQ expression;
variable_name: identifier;

if_expression
	: IF if_condition THEN true_expression ELSE false_expression
	;
if_condition: expression;
true_expression: expression;
false_expression: expression;

type_expression
	: primary_expression
	| TYPE primary_type
	;
type
	: OPEN_PARENS expression CLOSE_PARENS
	| primary_type
	;
primary_type
	: primitive_type
	| record_type
	| list_type
	| function_type
	| table_type
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
	: field_specification
	| field_specification COMMA field_specification_list
	;
field_specification
	: OPTIONAL? identifier field_type_specification?
	;
field_type_specification
	: EQ field_type
	;
field_type: type;
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
