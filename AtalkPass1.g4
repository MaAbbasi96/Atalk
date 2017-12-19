grammar AtalkPass1;

@header{
    import java.util.ArrayList;
}

@members{
}

program:
        {Utils.beginScope();}
		(actor | NL)*
        {
            if(!Utils.have_actor)
                Utils.print("No actor declared");
            if(!Utils.have_error)
                Utils.print(Utils.log);
            Utils.endScope();
        }
	;

actor:
		'actor' actor_name = ID '<' actor_box_size = CONST_NUM '>' NL
            {
                Utils.putActor($actor_name.text, $actor_box_size.int, $actor_name.getLine());
                Utils.have_actor = true;
                Utils.beginScope();
            }
			(state | receiver | NL)*
            {Utils.endScope();}
        'end' (NL | EOF)
	;

state:
        {ArrayList<String> ids = new ArrayList<>();}
		var_type = type var_id = ID {ids.add($var_id.text);} (',' var_id = ID{ids.add($var_id.text);})* NL
        {
            Utils.putGlobalVar($var_type.return_type, ids, $var_id.getLine());
        }
	;

receiver:
        {ArrayList<Variable> arguments = new ArrayList<>();}
		'receiver' receiver_name = ID '(' (var_type = type var_id = ID {arguments.add(new Variable($var_id.text, $var_type.return_type));}
        (',' var_type = type var_id = ID{arguments.add(new Variable($var_id.text, $var_type.return_type));})*)? ')' NL
            {Utils.putReciver(arguments,$receiver_name.getLine(),$receiver_name.text);}
			statements
            {Utils.endScope();}
		'end' NL
	;

type returns [Type return_type]:
        {ArrayList<Integer> dimension = new ArrayList<>();}
		'char' ('[' size = CONST_NUM ']'{dimension.add($size.int);})* {
            $return_type = CharType.getInstance();
            for(int i = dimension.size()-1; i >= 0; i--)
                $return_type = new ArrayType(dimension.get(i), $return_type);
        }
	|	{ArrayList<Integer> dimension = new ArrayList<>();}
        'int' ('[' size = CONST_NUM ']'{dimension.add($size.int);})*  {
        $return_type = IntType.getInstance();
        for(int i = dimension.size()-1; i >= 0; i--)
            $return_type = new ArrayType(dimension.get(i), $return_type);
        }
	;

block:
        {Utils.beginScope();}
		'begin' NL
			statements
		'end' NL
        {Utils.endScope();}
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
        {ArrayList<String> ids = new ArrayList<>();}
		var_type = type var_id = ID {ids.add($var_id.text);} ('=' expr)? (',' var_id = ID {ids.add($var_id.text);}('=' expr)?)* NL
        {
            Utils.putLocalVar(ids, $var_type.return_type, $var_id.getLine());
        }
	;

stm_tell:
		(ID | 'sender' | 'self') '<<' ID '(' (expr (',' expr)*)? ')' NL
	;

stm_write:
		'write' '(' expr ')' NL
	;

stm_if_elseif_else:
		'if' {Utils.beginScope();} expr NL statements {Utils.endScope();}
		('elseif' {Utils.beginScope();} expr NL statements {Utils.endScope();})*
		('else'{Utils.beginScope();} NL statements {Utils.endScope();})?
		'end' NL
	;

stm_foreach:
		'foreach' {Utils.beginScope();Utils.in_loop++;} ID 'in' expr NL
			statements
		'end' NL
        {
            Utils.endScope();
            Utils.in_loop--;
        }
	;

stm_quit:
		'quit' NL
	;

stm_break:
		break_var = 'break' NL
        {
            if(Utils.in_loop==0)
                Utils.print(String.format("[Line #%s] Break outside loop.", $break_var.getLine()));
        }
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
	|	ID
	|	'{' expr (',' expr)* '}'
	|	'read' '(' CONST_NUM ')'
	|	'(' expr ')'
	;

CONST_NUM:
		('-' | '+')?[0-9]+
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
