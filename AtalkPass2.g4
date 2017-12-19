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

expr returns [Type return_type]:
		expr_assign
        {$return_type = $expr_assign.return_type;}
	;

expr_assign returns [Type return_type]:
		expr_or '=' expr_assign
	|	expr_or {$return_type = $expr_or.return_type;}
	;

expr_or returns [Type return_type]:
		expr_and expr_or_tmp
        {$return_type = $expr_or_tmp.return_type;}
	;

expr_or_tmp returns [Type return_type]:
		'or' expr_and expr_or_tmp
        {$return_type = $expr_and.return_type;}
	|
	;

expr_and returns [Type return_type]:
		expr_eq expr_and_tmp
        {$return_type = $expr_and_tmp.return_type;}
	;

expr_and_tmp returns [Type return_type]:
		'and' expr_eq expr_and_tmp
        {$return_type = $expr_eq.return_type;}
	|
	;

expr_eq returns [Type return_type]:
		expr_cmp expr_eq_tmp
        {$return_type = $expr_eq_tmp.return_type;}
	;

expr_eq_tmp returns [Type return_type]:
		('==' | '<>') expr_cmp expr_eq_tmp
        {$return_type = $expr_cmp.return_type;}
	|
	;

expr_cmp returns [Type return_type]:
		expr_add expr_cmp_tmp
        {$return_type = $expr_cmp_tmp.return_type;}
	;

expr_cmp_tmp returns [Type return_type]:
		('<' | '>') expr_add expr_cmp_tmp
        {$return_type = $expr_add.return_type;}
	|
	;

expr_add returns [Type return_type]:
		expr_mult expr_add_tmp
        {$return_type = $expr_add_tmp.return_type;}

	;

expr_add_tmp returns [Type return_type]:
		('+' | '-') expr_mult expr_add_tmp
        {$return_type = $expr_mult.return_type;}
	|
	;

expr_mult returns [Type return_type]:
		expr_un expr_mult_tmp
        {$return_type = $expr_mult_tmp.return_type;}
	;

expr_mult_tmp returns [Type return_type]:
		('*' | '/') expr_un expr_mult_tmp
        {
        $return_type = $expr_un.return_type;
        if($return_type!= null)
        UtilsPass2.print($return_type.toString());}
	|
	;

expr_un returns [Type return_type]:
		('not' | '-') expr_un
	|	expr_mem { $return_type = $expr_mem.return_type;}
	;

expr_mem returns [Type return_type]:
		expr_other expr_mem_tmp
        { $return_type = $expr_other.return_type;}
	;

expr_mem_tmp returns [Type return_type]:
		'[' expr ']' expr_mem_tmp
        { $return_type = $expr.return_type;}
	|
	;

expr_other returns [Type return_type]:
		CONST_NUM { $return_type =  IntType.getInstance(); }
	|	CONST_CHAR{ $return_type =  CharType.getInstance(); }
	|	str = CONST_STR { $return_type = new ArrayType($str.text.length()-2,CharType.getInstance());}
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
