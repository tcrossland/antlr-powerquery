// As expression

as_expression // A1
	: equality_expression
	| equality_expression AS nullable_primitive_type
	;

// Equality expression

equality_expression // A2
	: relational_expression ((EQ | NE) relational_expression)*
	;

relational_expression // A3
	: additive_expression (('<' | '>' | '<=' | '>=') additive_expression)*
	;

additive_expression // A4
	: multiplicative_expression (('+' | '-')  multiplicative_expression)*
	;

multiplicative_expression // A5
	: metadata_expression (('*' | '/') metadata_expression)*
	;

metadata_expression // A6
	: as_expression (META unary_expression)*
	;

// REFERENCED RULES
unary_expression: IDENTIFIER;
nullable_primitive_type: NULLABLE? ANY;
epsilon: TRUE;

/*
https://mpeveler.com/assets/content/projects/cfg2cnf.php

S as_expression
Q equality_expression
R relational_expression
A additive_expression
M multiplicative_expression
X metadata_expression
n nullable_primitive_type
s AS
q EQ
c COMP
a + -
m * /
x meta
u unary_expression

Original:
S->Q|Ssn
Q->R|RqQ
R->A|AcR
A->M|MaA
M->X|XmM
X->S|Sxu

New:
S0 -> SB | RC | AD | ME | XF | SG
S -> SB | RC | AD | ME | XF | SG
Q -> RC | AD | ME | XF | SG | SB
R -> AD | ME | XF | SG | SB | m
A -> ME | XF | SG | SB
M -> XF | SG | SB
X -> SG | SB
B -> HJ
C -> LQ
D -> NR
E -> PA
F -> RM
G -> UW
H -> s
J -> n
L -> q
N -> c
P -> a
U -> x
W -> u

*/