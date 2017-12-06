grammar Atalk;

@header{
    import java.util.ArrayList;
}

@members{
    boolean have_actor = false;
    boolean in_loop = false;

    void print(String str){
        System.out.println(str);
    }

    void beginScope() {
        int offset = 0;
        if(SymbolTable.top != null)
            offset = SymbolTable.top.getOffset(Register.SP);
        SymbolTable.push(new SymbolTable(SymbolTable.top));
        SymbolTable.top.setOffset(Register.SP, offset);
    }

    void putLocalVar(String name, Type type) throws ItemAlreadyExistsException, InvalidArgumentException {
        if(!type.is_valid())
            throw new InvalidArgumentException();
        SymbolTable.top.put(
            new SymbolTableLocalVariableItem(
                new Variable(name, type),
                SymbolTable.top.getOffset(Register.SP)
            )
        );
    }

    void putActor(String name, int box_size) throws ItemAlreadyExistsException, InvalidArgumentException {
        if(box_size <= 0)
            throw new InvalidArgumentException();
        SymbolTable.top.put(
            new SymbolTableActorItem(
                new Actor(name, box_size)
            )
        );
    }

    void putReceiver(String name, ArrayList<Variable> arguments) throws ItemAlreadyExistsException {
        SymbolTable.top.put(
            new SymbolTableReceiverItem(
                new Receiver(name, arguments)
            )
        );
    }

	void endScope() {
	     print("Stack offset: " + SymbolTable.top.getOffset(Register.SP));
	     SymbolTable.pop();
    }

}

program:
        {beginScope();}
		(actor | NL)*
        {
            if(!have_actor)
                print("Actor not declared");
            endScope();
        }
	;

actor:
        {Boolean flag = true;}
		'actor' actor_name = ID '<' actor_box_size = CONST_NUM '>' NL
            {
                try{
                    putActor($actor_name.text, $actor_box_size.int);
                    have_actor = true;
                    beginScope();
                }
                catch(ItemAlreadyExistsException ex) {
                	print(String.format("[Line #%s] Actor \"%s\" already exists.", $actor_name.getLine(), $actor_name.text));
                    flag = false;
                }
                catch(InvalidArgumentException e){
                    print("Wrong Box Size");
                    flag = false;
                }
            }
			(state | receiver | NL)*
            {if(flag) endScope();}
        'end' (NL | EOF)
	;

state:
		var_type = type var_id = ID (',' ID)* NL
        {
            try {
                putLocalVar($var_id.text, $var_type.return_type);
            }
            catch(ItemAlreadyExistsException ex) {
            	print(String.format("[Line #%s] Variable \"%s\" already exists.", $var_id.getLine(), $var_id.text));
            }
            catch(InvalidArgumentException e){
                print("Wrong Size");
            }
        }
	;

receiver:
        {
            ArrayList<Variable> arguments = new ArrayList<>();
            Boolean flag = true;
        }
		'receiver' receiver_name = ID '(' (var_type = type var_id = ID {arguments.add(new Variable($var_id.text, $var_type.return_type));}
        (',' var_type = type var_id = ID{arguments.add(new Variable($var_id.text, $var_type.return_type));})*)? ')' NL
        {
            try{
                putReceiver($receiver_name.text, arguments);
                beginScope();
                for(int i = 0; i < arguments.size(); i++){
                    try{
                        putLocalVar(arguments.get(i).getName(), arguments.get(i).getType());
                    }
                    catch(ItemAlreadyExistsException ex) {
                    	print(String.format("[Line #%s] Variable \"%s\" already exists.", $var_id.getLine(), $var_id.text));
                    }
                    catch(InvalidArgumentException e){
                        print("Wrong Size");
                    }
                }
            }
            catch(ItemAlreadyExistsException ex) {
                flag = false;
                print(String.format("[Line #%s] Actor \"%s\" already exists.", $receiver_name.getLine(), $receiver_name.text));
            }
        }
			statements
		'end' NL
        {if(flag) endScope();}
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
        {beginScope();}
		'begin' NL
			statements
		'end' NL
        {endScope();}
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
		var_type = type var_id = ID ('=' expr)? (',' ID ('=' expr)?)* NL
        {
            try {
                putLocalVar($var_id.text, $var_type.return_type);
            }
            catch(ItemAlreadyExistsException ex) {
            	print(String.format("[Line #%s] Variable \"%s\" already exists.", $var_id.getLine(), $var_id.text));
            }
            catch(InvalidArgumentException e){
                print("Wrong Size");
            }
        }
	;

stm_tell:
		(ID | 'sender' | 'self') '<<' ID '(' (expr (',' expr)*)? ')' NL
	;

stm_write:
		'write' '(' expr ')' NL
	;

stm_if_elseif_else:
        {beginScope();}
		'if' expr NL statements
		('elseif' expr NL statements)*
		('else' NL statements)?
		'end' NL
        {endScope();}
	;

stm_foreach:
        {
            beginScope();
            in_loop = true;
        }
		'foreach' ID 'in' expr NL
			statements
		'end' NL
        {
            endScope();
            in_loop = false;
        }
	;

stm_quit:
		'quit' NL
	;

stm_break:
		'break' NL
        {
            if(!in_loop)
                print("not in a loop");
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
