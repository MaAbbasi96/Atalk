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
		'actor' actor_name = ID '<' actor_box_size = CONST_NUM '>' NL
            {
                try{
                    putActor($actor_name.text, $actor_box_size.int);
                    print("Actor: " + $actor_name.text + " with size: " + $actor_box_size.text);
                    have_actor = true;
                }
                catch(ItemAlreadyExistsException ex) {
                	print(String.format("[Line #%s] Actor \"%s\" already exists.", $actor_name.getLine(), $actor_name.text));
                    try{
                        putActor($actor_name.text+"_temp_1", $actor_box_size.int);
                    }
                    catch(ItemAlreadyExistsException ex1){}
                    catch(InvalidArgumentException e1){}
                }
                catch(InvalidArgumentException e){
                    print(String.format("[Line #%s] Actor \"%s\" wrong box size.", $actor_name.getLine(), $actor_name.text));
                    try{
                        putActor($actor_name.text, 0);
                    }
                    catch(ItemAlreadyExistsException ex1){}
                    catch(InvalidArgumentException e1){}
                }
                finally{
                    beginScope();
                }
            }
			(state | receiver | NL)*
            {endScope();}
        'end' (NL | EOF)
	;

state:
        {ArrayList<String> ids = new ArrayList<>();}
		var_type = type var_id = ID {ids.add($var_id.text);} (',' var_id = ID{ids.add($var_id.text);})* NL
        {
            for(int i = 0; i < ids.size(); i++){
                try {
                    putLocalVar(ids.get(i), $var_type.return_type);
                    print("ID: " + ids.get(i) + " with type: " + $var_type.return_type + " and size: " + $var_type.return_type.size() + " and offset: " + (SymbolTable.top.getOffset(Register.SP) - $var_type.return_type.size()));
                }
                catch(ItemAlreadyExistsException ex) {
            	    print(String.format("[Line #%s] Variable \"%s\" already exists.", $var_id.getLine(), ids.get(i)));
                    try{
                           putLocalVar(ids.get(i)+"_temp_1", $var_type.return_type);
                    }
                    catch(ItemAlreadyExistsException ex1){}
                    catch(InvalidArgumentException e1){}
                }
                catch(InvalidArgumentException e){
                    print(String.format("[Line #%s] Variable \"%s\" wrong size.", $var_id.getLine(), ids.get(i)));
                    try{
                        SymbolTable.top.put(
                            new SymbolTableLocalVariableItem(
                                new Variable(ids.get(i), $var_type.return_type),
                                SymbolTable.top.getOffset(Register.SP)
                            )
                        );
                    }
                    catch(ItemAlreadyExistsException ex1){}
                }
            }
        }
	;

receiver:
        {ArrayList<Variable> arguments = new ArrayList<>();}
		'receiver' receiver_name = ID '(' (var_type = type var_id = ID {arguments.add(new Variable($var_id.text, $var_type.return_type));}
        (',' var_type = type var_id = ID{arguments.add(new Variable($var_id.text, $var_type.return_type));})*)? ')' NL
        {
            try{
                putReceiver($receiver_name.text, arguments);
                print("Receiver: " + $receiver_name.text + " with arguments:");
                if(arguments.size() == 0)
                    print("no arguments!!!");
                for(int i = 0; i < arguments.size(); i++)
                    print(arguments.get(i).toString() + ",");
            }
            catch(ItemAlreadyExistsException ex) {
                print(String.format("[Line #%s] Actor \"%s\" already exists.", $receiver_name.getLine(), $receiver_name.text));
                try{
                    putReceiver($receiver_name.text+"_temp_1", arguments);
                }
                catch(ItemAlreadyExistsException ex1){}
            }
            finally{
                beginScope();
                for(int i = 0; i < arguments.size(); i++){
                    try{
                        putLocalVar(arguments.get(i).getName(), arguments.get(i).getType());
                    }
                    catch(ItemAlreadyExistsException ex) {
                    	print(String.format("[Line #%s] Variable \"%s\" already exists.", $var_id.getLine(), $var_id.text));
                        try{
                            putLocalVar($var_id.text+"_temp_1", $var_type.return_type);
                        }
                        catch(ItemAlreadyExistsException ex1){}
                        catch(InvalidArgumentException e1){}
                    }
                    catch(InvalidArgumentException e){
                        print(String.format("[Line #%s] Variable \"%s\" wrong size.", $var_id.getLine(), $var_id.text));
                        try{
                            SymbolTable.top.put(
                                new SymbolTableLocalVariableItem(
                                    new Variable($var_id.text, $var_type.return_type),
                                    SymbolTable.top.getOffset(Register.SP)
                                )
                            );
                        }
                        catch(ItemAlreadyExistsException ex1){}
                    }
                }
            }
        }
			statements
		'end' NL
        {endScope();}
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
        {ArrayList<String> ids = new ArrayList<>();}
		var_type = type var_id = ID {ids.add($var_id.text);} ('=' expr)? (',' var_id = ID {ids.add($var_id.text);}('=' expr)?)* NL
        {
            for(int i = 0; i < ids.size(); i++){
                try {
                    putLocalVar(ids.get(i), $var_type.return_type);
                    print("ID: " + ids.get(i) + " with type: " + $var_type.return_type + " and size: " + $var_type.return_type.size() + " and offset: " + (SymbolTable.top.getOffset(Register.SP) - $var_type.return_type.size()));
                }
                catch(ItemAlreadyExistsException ex) {
            	    print(String.format("[Line #%s] Variable \"%s\" already exists.", $var_id.getLine(), ids.get(i)));
                    try{
                        putLocalVar(ids.get(i)+"_temp_1", $var_type.return_type);
                    }
                    catch(ItemAlreadyExistsException ex1){}
                    catch(InvalidArgumentException e1){}
                }
                catch(InvalidArgumentException e){
                    print(String.format("[Line #%s] Variable \"%s\" wrong size.", $var_id.getLine(), ids.get(i)));
                    try{
                        SymbolTable.top.put(
                            new SymbolTableLocalVariableItem(
                                new Variable(ids.get(i), $var_type.return_type),
                                    SymbolTable.top.getOffset(Register.SP)
                            )
                        );
                    }
                    catch(ItemAlreadyExistsException ex1){}
                }
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
		break_var = 'break' NL
        {
            if(!in_loop)
                print(String.format("[Line #%s] Break outside loop.", $break_var.getLine()));
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
