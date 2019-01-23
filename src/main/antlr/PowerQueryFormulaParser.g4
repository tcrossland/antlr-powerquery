parser grammar PowerQueryFormulaParser;

options { tokenVocab=PowerQueryFormulaLexer; }

sectionDocument: section;

section
	: literalAttributes? SECTION IDENTIFIER? SEMICOLON sectionMember*;

sectionMember
	: literalAttributes? SHARED? IDENTIFIER EQ expression SEMICOLON;

expressionDocument: expression;

expression
	: logicalExpression
	| eachExpression
	| functionExpression
	| letExpression
	| ifExpression
	| errorRaisingExpression
	| errorHandlingExpression
	;

logicalExpression
	: logicalOrExpression
	| logicalAndExpression
	;

logicalOrExpression
	: logicalAndExpression (OR logicalAndExpression)*
	;

logicalAndExpression
	: isExpression (AND isExpression)*
	;

isExpression
	: asExpression (IS nullablePrimitiveType)*
	;

nullablePrimitiveType
	: NULLABLE? primitiveType
	;

asExpression
	: equalityExpression (AS nullablePrimitiveType)*
	;

equalityExpression
	: relationalExpression ((EQ | NE) relationalExpression)*
	;

relationalExpression
	: additiveExpression ((LT | GT | LE | GE) additiveExpression)*
	;

additiveExpression
	: multiplicativeExpression ((PLUS | MINUS | AMP) multiplicativeExpression)*
	;

multiplicativeExpression
	: metaExpression ((STAR | DIV) metaExpression)*
	;

metaExpression
	: unaryExpression (META unaryExpression)*
	;

unaryExpression
	: typeExpression
	| PLUS unaryExpression
	| MINUS unaryExpression
	| NOT unaryExpression
	;

primaryExpression
	: anyLiteral                                                      #literalExpression
	| OPEN_BRACE itemList? CLOSE_BRACE                                #listExpression
	| OPEN_BRACKET fieldList? CLOSE_BRACKET                           #recordExpression
	| IDENTIFIER                                                      #identifierExpression
	| AT IDENTIFIER                                                   #identifierExpression
	| IDENTIFIER BANG IDENTIFIER                                      #sectionAccessExpression
	| OPEN_PARENS expression CLOSE_PARENS                             #parenthesizedExpression
	| fieldAccessExpression                                           #primaryExpression_fieldAccessExpression
	| primaryExpression OPEN_BRACE itemSelector CLOSE_BRACE QUESTION? #itemAccessExpression
	| primaryExpression OPEN_PARENS argumentList? CLOSE_PARENS        #invokeExpression
	| DOT_DOT_DOT                                                     #notImplementedExpression
	| intrinsicFunctionExpression                                     #builtinFunctionExpression
	;

intrinsicFunctionExpression
	: HASH_TABLE
	;

// Left corner transform has been applied to field-access-expression/primary-expression to remove mutually left recursive rules
fieldAccessExpression
	: (TEXT_LITERAL | NUMBER_LITERAL) fieldAccessExpression_LITERAL  #fieldSelectionOrProjection
	| OPEN_BRACE fieldAccessExpression_OPEN_BRACE                    #fieldSelectionOrProjection
	| OPEN_BRACKET fieldAccessExpression_OPEN_BRACKET                #implicitTargetSelectionOrProjection
	| IDENTIFIER fieldAccessExpression_IDENTIFIER                    #fieldSelectionOrProjection
	| AT fieldAccessExpression_AT                                    #fieldSelectionOrProjection
	| OPEN_PARENS fieldAccessExpression_OPEN_PARENS                  #fieldSelectionOrProjection
	| DOT_DOT_DOT fieldAccessExpression_DOT_DOT_DOT                  #fieldSelectionOrProjection
	;

fieldAccessExpression_primaryExpression
	: fieldSelector                                                                           #fieldSelection // fieldSelection
	| OPEN_BRACKET requiredSelectorList CLOSE_BRACKET QUESTION?                               #projection     // projection
	| OPEN_BRACE itemSelector CLOSE_BRACE QUESTION? fieldAccessExpression_primaryExpression   #fieldAccessExpression_primaryExpression_itemAccessExpression // itemAccessExpression...
	| OPEN_PARENS argumentList? CLOSE_PARENS fieldAccessExpression_primaryExpression          #fieldAccessExpression_primaryExpression_invokeExpression     // invokeExpression...
	;

// X: [primaryExpression, fieldSelector]
fieldAccessExpression_LITERAL
	: fieldAccessExpression_primaryExpression                                                 // literalExpression...
	;
fieldAccessExpression_OPEN_BRACE
	: itemList? CLOSE_BRACE fieldAccessExpression_primaryExpression                           // listExpression...
	;
fieldAccessExpression_OPEN_BRACKET
	: fieldList CLOSE_BRACKET fieldAccessExpression_primaryExpression                         #recordExpression_fieldAccess // recordExpression...
	| fieldName CLOSE_BRACKET QUESTION?                                                       #implicitTargetFieldSelection // requiredFieldSelector/optionalFieldSelector
	;
fieldAccessExpression_IDENTIFIER
	: fieldAccessExpression_primaryExpression                                                 // identifierExpression...
	| BANG IDENTIFIER fieldAccessExpression_primaryExpression                                 // sectionAccessExpression...
	;
fieldAccessExpression_AT
	: IDENTIFIER fieldAccessExpression_primaryExpression                                      // identifierExpression...
	;
fieldAccessExpression_OPEN_PARENS
	: expression CLOSE_PARENS fieldAccessExpression_primaryExpression                         // parenthesizedExpresion...
	;
fieldAccessExpression_fieldAccessExpression
	: fieldAccessExpression_primaryExpression                                                 // fieldAccessExpression...
	;
fieldAccessExpression_DOT_DOT_DOT
	: fieldAccessExpression_primaryExpression                                                 // notImplementedExpression...
	;
// corners: [fieldSelector, field_access_expression, requiredFieldSelector, optionalFieldSelector]
// corners: [requiredFieldSelector, optionalFieldSelector]

argumentList
	: expression (COMMA expression)*
	;

itemList
	: item (COMMA item)*
	;

item
	: expression                    # singleItem
	| expression DOT_DOT expression # sequence
	;

fieldList
	: field (COMMA field)*
	;

field: fieldName EQ expression;

fieldName: GENERALIZED_IDENTIFIER | IDENTIFIER;

itemSelector: expression;

fieldSelector
	: requiredFieldSelector
	| optionalFieldSelector
	;

requiredFieldSelector: OPEN_BRACKET fieldName CLOSE_BRACKET;
optionalFieldSelector: OPEN_BRACKET fieldName CLOSE_BRACKET QUESTION;

requiredSelectorList
	: requiredFieldSelector (COMMA requiredFieldSelector)*
	;

functionExpression
	: OPEN_PARENS parameterList? CLOSE_PARENS returnType? ARROW functionBody;
functionBody: expression;
parameterList
	: fixedParameterList (COMMA optionalParameterList)?
	| optionalParameterList
	;
fixedParameterList
	: parameter (COMMA parameter)*
	;
parameter
	: parameterName parameterType?
	;
parameterName
	: IDENTIFIER
	;
parameterType
	: assertion
	;
returnType
	: assertion
	;
assertion
	: AS type
	;
optionalParameterList
	: optionalParameter (COMMA optionalParameter)*
	;
optionalParameter
	: OPTIONAL parameter
	;
eachExpression
	: EACH eachExpressionBody
	;
eachExpressionBody: functionBody;
letExpression
	: LET variableList IN expression
	;
variableList
	: variable (COMMA variable)*
	;
variable: variableName EQ expression;
variableName: GENERALIZED_IDENTIFIER | IDENTIFIER;

ifExpression
	: IF ifCondition THEN trueExpression ELSE falseExpression
	;
ifCondition: expression;
trueExpression: expression;
falseExpression: expression;

typeExpression
	: TYPE primaryType
	| primaryExpression
	;
type
	: OPEN_PARENS expression CLOSE_PARENS
	| primaryType
	;
primaryType
	: tableType
	| primitiveType
	| recordType
	| listType
	| functionType
	| nullableType
	;
primitiveType
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
recordType
	: OPEN_BRACKET openRecordMarker CLOSE_BRACKET
	| OPEN_BRACKET fieldSpecificationList CLOSE_BRACKET
	| OPEN_BRACKET fieldSpecificationList COMMA openRecordMarker CLOSE_BRACKET
	;
fieldSpecificationList
	: fieldSpecification (COMMA fieldSpecification)*
	;
fieldSpecification
	: IDENTIFIER fieldTypeSpecification?
	| GENERALIZED_IDENTIFIER fieldTypeSpecification?
	| OPTIONAL IDENTIFIER fieldTypeSpecification?
	| OPTIONAL GENERALIZED_IDENTIFIER fieldTypeSpecification?
	;
fieldTypeSpecification
	: EQ fieldType
	;
fieldType
	: type
	| IDENTIFIER;
openRecordMarker: DOT_DOT_DOT;
listType: OPEN_BRACE itemType CLOSE_BRACE;
itemType: type;
functionType: FUNCTION OPEN_PARENS parameterSpecificationList? CLOSE_PARENS returnType;
parameterSpecificationList
	: requiredParameterSpecificationList
	| requiredParameterSpecificationList COMMA optionalParameterSpecificationList
	| optionalParameterSpecificationList
	;
requiredParameterSpecificationList
	: parameterSpecification (COMMA parameterSpecification)*
	;
optionalParameterSpecificationList
	: optionalParameterSpecification (COMMA optionalParameterSpecification)*
	;
optionalParameterSpecification
	: OPTIONAL parameterSpecification
	;
parameterSpecification
	: parameterName parameterType
	;
tableType
	: TABLE rowType
	;
rowType
	: OPEN_BRACKET fieldSpecificationList CLOSE_BRACKET
	;
nullableType
	: NULLABLE type
	;

errorRaisingExpression
	: ERROR expression
	;
errorHandlingExpression
	: TRY protectedExpression otherwiseClause?
	;
protectedExpression: expression;
otherwiseClause: OTHERWISE defaultExpression;
defaultExpression: expression;

literalAttributes: recordLiteral;
recordLiteral: OPEN_BRACKET literalFieldList? CLOSE_BRACKET;
literalFieldList
	: literalField (COMMA literalField)*;
literalField
	: fieldName EQ anyLiteral
	;
listLiteral
	: OPEN_BRACE literalItemList CLOSE_BRACE
	;
literalItemList
	: anyLiteral (COMMA anyLiteral)*
	;
anyLiteral
	: recordLiteral
	| listLiteral
	| logicalLiteral 
	| numberLiteral
	| textLiteral
	| nullLiteral
	;

numberLiteral: NUMBER_LITERAL;

textLiteral: TEXT_LITERAL;

nullLiteral: NULL;

logicalLiteral
	: TRUE
	| FALSE
	;
