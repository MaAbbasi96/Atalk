grammar AtalkPass2;

program:
        {
            UtilsPass2.print("Pass2 started -------------------------");
            UtilsPass2.beginScope();
        }
		(actor | NL)*
        {
            UtilsPass2.endScope();
            UtilsPass2.print("Pass2 finished -------------------------");
        }
	;

actor:
		'actor' ID '<' CONST_NUM '>' NL
        {UtilsPass2.beginScope();}
			(state | receiver | NL)*
		'end' (NL | EOF)
        {UtilsPass2.endScope();}
	;

state:
		type ID (',' ID)* NL
	;

receiver:
        { int counter = 0; }
		'receiver' ID '(' (type ID {counter++;} (',' type ID {counter++;}  )*)? ')' NL
        {UtilsPass2.beginScope();}
            {
                for(int i=0; i<counter; i++)
                    SymbolTable.define();
            }
			statements
		'end' NL
        {UtilsPass2.endScope();}
	;

type:
		'char' ('[' CONST_NUM ']')*
	|	'int' ('[' CONST_NUM ']')*
	;

block:
		'begin' NL
        {UtilsPass2.beginScope();}
			statements
		'end' NL
        {UtilsPass2.endScope();}
	;

statements:
		(statement | NL)*
	;

statement:
		stm_vardef
	|	stm_assignment
	|	stm_foreach
	|	stm_if_elseif_else
	|	stm_quit
	|	stm_break
	|	stm_tell
	|	stm_write
	|	block
	;

stm_vardef:
		type ID {SymbolTable.define();} ('=' expr)? (',' ID {SymbolTable.define();} ('=' expr)?)* NL
	;

stm_tell:
		(actorName = ID | 'sender' | 'self') '<<' funcName = ID '(' (expr (',' expr)*)? ')' NL
        {UtilsPass2.check_actor($actorName.text, $funcName.text, $actorName.getLine());}
	;

stm_write:
		'write' '(' expr ')' NL
	;

stm_if_elseif_else:
		'if'{UtilsPass2.beginScope();} expr NL statements {UtilsPass2.endScope();}
		('elseif'{UtilsPass2.beginScope();} expr NL statements {UtilsPass2.endScope();})*
		('else'{UtilsPass2.beginScope();} NL statements{UtilsPass2.endScope();})?
		'end' NL
	;

stm_foreach:
        {UtilsPass2.beginScope();}
		'foreach' ID 'in' expr NL
			statements
		'end' NL
        {UtilsPass2.endScope();}
	;

stm_quit:
		'quit' NL
	;

stm_break:
		'break' NL
	;

stm_assignment:
		expr NL
	;

expr:
		expr_assign
	;

expr_assign:
		expr_or '=' expr_assign
	|	expr_or
	;

expr_or:
		expr_and expr_or_tmp
	;

expr_or_tmp:
		'or' expr_and expr_or_tmp
	|
	;

expr_and:
		expr_eq expr_and_tmp
	;

expr_and_tmp:
		'and' expr_eq expr_and_tmp
	|
	;

expr_eq:
		expr_cmp expr_eq_tmp
	;

expr_eq_tmp:
		('==' | '<>') expr_cmp expr_eq_tmp
	|
	;

expr_cmp:
		expr_add expr_cmp_tmp
	;

expr_cmp_tmp:
		('<' | '>') expr_add expr_cmp_tmp
	|
	;

expr_add:
		expr_mult expr_add_tmp
	;

expr_add_tmp:
		('+' | '-') expr_mult expr_add_tmp
	|
	;

expr_mult:
		expr_un expr_mult_tmp
	;

expr_mult_tmp:
		('*' | '/') expr_un expr_mult_tmp
	|
	;

expr_un:
		('not' | '-') expr_un
	|	expr_mem
	;

expr_mem:
		expr_other expr_mem_tmp
	;

expr_mem_tmp:
		'[' expr ']' expr_mem_tmp
	|
	;

expr_other:
		CONST_NUM
	|	CONST_CHAR
	|	CONST_STR
	|	name = ID {UtilsPass2.def_check($name.text, $name.getLine());}
	|	'{' expr (',' expr)* '}'
	|	'read' '(' CONST_NUM ')'
	|	'(' expr ')'
	;

CONST_NUM:
		[0-9]+
	;

CONST_CHAR:
		'\'' . '\''
	;

CONST_STR:
		'"' ~('\r' | '\n' | '"')* '"'
	;

NL:
		'\r'? '\n' { setText("new_line"); }
	;

ID:
		[a-zA-Z_][a-zA-Z0-9_]*
	;

COMMENT:
		'#'(~[\r\n])* -> skip
	;

WS:
    	[ \t] -> skip
    ;
