grammar Atalk;

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
                try{
                    Utils.putActor($actor_name.text, $actor_box_size.int);
                    Utils.log += "Actor: " + $actor_name.text + " with size: " + $actor_box_size.text + "\n";
                }
                catch(ItemAlreadyExistsException ex) {
                    Utils.have_error = true;
                	Utils.print(String.format("[Line #%s] Actor \"%s\" already exists.", $actor_name.getLine(), $actor_name.text));
                    try{
                        Utils.putActor($actor_name.text+"_temp_1", $actor_box_size.int);
                    }
                    catch(ItemAlreadyExistsException ex1){}
                    catch(InvalidArgumentException e1){}
                }
                catch(InvalidArgumentException e){
                    Utils.have_error = true;
                    Utils.print(String.format("[Line #%s] Actor \"%s\" wrong box size.", $actor_name.getLine(), $actor_name.text));
                    try{
                        SymbolTable.top.put(
                            new SymbolTableActorItem(
                                new Actor($actor_name.text, 0)
                            )
                        );
                    }
                    catch(ItemAlreadyExistsException ex1){
                        Utils.print(String.format("[Line #%s] Actor \"%s\" already exists.", $actor_name.getLine(), $actor_name.text));
                    }
                }
                finally{
                    Utils.have_actor = true;
                    Utils.beginScope();
                }
            }
			(state | receiver | NL)*
            {Utils.endScope();}
        'end' (NL | EOF)
	;

state:
        {ArrayList<String> ids = new ArrayList<>();}
		var_type = type var_id = ID {ids.add($var_id.text);} (',' var_id = ID{ids.add($var_id.text);})* NL
        {
            for(int i = 0; i < ids.size(); i++){
                try {
                    Utils.putGlobalVar(ids.get(i), $var_type.return_type);
                    Utils.log += "ID: " + ids.get(i) + " with type: " + $var_type.return_type + " and size: " + $var_type.return_type.size() + " and Global offset: " + (SymbolTable.top.getOffset(Register.GP) - $var_type.return_type.size()) + "\n";
                }
                catch(ItemAlreadyExistsException ex) {
                    Utils.have_error = true;
            	    Utils.print(String.format("[Line #%s] Variable \"%s\" already exists.", $var_id.getLine(), ids.get(i)));
                    try{
                           Utils.putGlobalVar(ids.get(i)+"_temp_1", $var_type.return_type);
                    }
                    catch(ItemAlreadyExistsException ex1){}
                    catch(InvalidArgumentException e1){}
                }
                catch(InvalidArgumentException e){
                    Utils.have_error = true;
                    Utils.print(String.format("[Line #%s] Variable \"%s\" wrong size.", $var_id.getLine(), ids.get(i)));
                    try{
                        SymbolTable.top.put(
                            new SymbolTableGlobalVariableItem(
                                new Variable(ids.get(i), $var_type.return_type),
                                SymbolTable.top.getOffset(Register.GP)
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
                Utils.putReceiver($receiver_name.text, arguments);
                Utils.log += "Receiver: " + $receiver_name.text + " with arguments:" + "\n";
                if(arguments.size() == 0)
                    Utils.log += "no arguments!!!\n";
                for(int i = 0; i < arguments.size(); i++)
                    Utils.log += arguments.get(i).toString() + ",\n";
            }
            catch(ItemAlreadyExistsException ex) {
                Utils.have_error = true;
                Utils.print(String.format("[Line #%s] Receiver \"%s\" already exists.", $receiver_name.getLine(), $receiver_name.text));
                try{
                    Utils.putReceiver($receiver_name.text+"_temp_1", arguments);
                }
                catch(ItemAlreadyExistsException ex1){}
            }
            finally{
                Utils.beginScope();
                for(int i = 0; i < arguments.size(); i++){
                    try{
                        Utils.putLocalVar(arguments.get(i).getName(), arguments.get(i).getType());
                    }
                    catch(ItemAlreadyExistsException ex) {
                        Utils.have_error = true;
                    	Utils.print(String.format("[Line #%s] Variable \"%s\" already exists.", $var_id.getLine(), $var_id.text));
                        try{
                            Utils.putLocalVar($var_id.text+"_temp_1", $var_type.return_type);
                        }
                        catch(ItemAlreadyExistsException ex1){}
                        catch(InvalidArgumentException e1){}
                    }
                    catch(InvalidArgumentException e){
                        Utils.have_error = true;
                        Utils.print(String.format("[Line #%s] Variable \"%s\" wrong size.", $var_id.getLine(), $var_id.text));
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
        {Utils.endScope();}
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
            for(int i = 0; i < ids.size(); i++){
                try {
                    Utils.putLocalVar(ids.get(i), $var_type.return_type);
                    Utils.log += "ID: " + ids.get(i) + " with type: " + $var_type.return_type + " and size: " + $var_type.return_type.size() + " and offset: " + (SymbolTable.top.getOffset(Register.SP) - $var_type.return_type.size()) + "\n";
                }
                catch(ItemAlreadyExistsException ex) {
                    Utils.have_error = true;
            	    Utils.print(String.format("[Line #%s] Variable \"%s\" already exists.", $var_id.getLine(), ids.get(i)));
                    try{
                        Utils.putLocalVar(ids.get(i)+"_temp_1", $var_type.return_type);
                    }
                    catch(ItemAlreadyExistsException ex1){}
                    catch(InvalidArgumentException e1){}
                }
                catch(InvalidArgumentException e){
                    Utils.have_error = true;
                    Utils.print(String.format("[Line #%s] Variable \"%s\" wrong size.", $var_id.getLine(), ids.get(i)));
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
        {Utils.beginScope();}
		'if' expr NL statements
		('elseif' expr NL statements)*
		('else' NL statements)?
		'end' NL
        {Utils.endScope();}
	;

stm_foreach:
        {
            Utils.beginScope();
            Utils.in_loop = true;
        }
		'foreach' ID 'in' expr NL
			statements
		'end' NL
        {
            Utils.endScope();
            Utils.in_loop = false;
        }
	;

stm_quit:
		'quit' NL
	;

stm_break:
		break_var = 'break' NL
        {
            if(!Utils.in_loop)
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
