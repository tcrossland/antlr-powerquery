parser grammar pq;

options { tokenVocab=PowerQueryFormulaLexer; }

nullable_primitive_type
	: NULLABLE? primitive_type
	;

// As expression

as_expression // A1
	: equality_expression as_nullable?
	;

// Equality expression

equality_expression: relational_expression op_equality?;
relational_expression: additive_expression op_relational?;
additive_expression: multiplicative_expression op_additive?;
multiplicative_expression: metadata_expression op_multiplicative?;
metadata_expression: as_expression meta_unary?;
metadata_expression_dash
	: meta_unary? metadata_expression_dash
	| /* epsilon */
	;

as_nullable
	: (AS nullable_primitive_type)
	;

op_equality
	: ((EQ | NE) equality_expression)
	;

op_relational
	: (('<' | '>' | '<=' | '>=') relational_expression)
	;

op_additive
	: (('+' | '-' | '&')  additive_expression)
	;

op_multiplicative
	:  (('*' | '/') multiplicative_expression)
	;

meta_unary
	: (META unary_expression)
	;

/// OUT OF SIGHT
unary_expression
	: NOT
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
