grammar AtalkPass2;

@members{
    Translator mips = new Translator();
}

program:
        {
            UtilsPass2.print("Pass2 started -------------------------");
            UtilsPass2.beginScope();
        }
		(actor | NL)*
        {
            UtilsPass2.endScope();
            UtilsPass2.print("Pass2 finished -------------------------");
            mips.makeOutput();
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
		type var_id = ID (',' ID)* NL
        {
            SymbolTableVariableItemBase var = (SymbolTableVariableItemBase) SymbolTable.top.get($var_id.text);
            mips.addGlobalVariable(var.getOffset(), 0);
        }
	;

receiver:
        { int counter = 0; }
		'receiver' name = ID '(' (type ID {counter++;} (',' type ID {counter++;}  )*)? ')' NL
        {
            UtilsPass2.beginScope();
            if($name.text.equals("init") && counter == 0)
                UtilsPass2.init_with_no_args = true;
            for(int i=0; i<counter; i++)
                SymbolTable.define();
        }
			statements
		'end' NL
        {
            UtilsPass2.endScope();
            UtilsPass2.init_with_no_args = false;
        }
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

stm_vardef: {int exp_value = 0;}
		type ID ('=' expr)? {
            SymbolTable.define();
            mips.addToStack(exp_value);
        }
        (',' ID ('=' expr)? {
            exp_value = 0;
            SymbolTable.define();
            mips.addToStack(exp_value);
        } )* NL
	;

stm_tell:
        {ArrayList<String> args = new ArrayList<>();}
		actorName = (ID | 'sender' | 'self') '<<' funcName = ID '(' (temp = expr{args.add($temp.return_type.toString());} (',' temp = expr {args.add($temp.return_type.toString());})*)? ')' NL
        {UtilsPass2.tell_check($actorName.text, $funcName.text, $actorName.getLine(), args);}
	;

stm_write:
		'write' '(' expr ')' temp = NL {
            if(!$expr.return_type.get_sub_array(1).equals(CharType.getInstance()))
                UtilsPass2.print("Error " + $temp.getLine() + ") Invalid argument for Write function");
            if($expr.return_type.toString().equals("notype"))
                UtilsPass2.print("Error " + $temp.getLine() + ") " + "Invalid Operation");
            mips.write();
        }
	;

stm_if_elseif_else:
		temp = 'if'{UtilsPass2.beginScope();} expr{if($expr.return_type.toString().equals("notype")) UtilsPass2.print("Error " + $temp.getLine() + ") " + "Invalid Operation");} NL statements {UtilsPass2.endScope();}
		(temp = 'elseif'{UtilsPass2.beginScope();} expr{if($expr.return_type.toString().equals("notype")) UtilsPass2.print("Error " + $temp.getLine() + ") " + "Invalid Operatio");} NL statements {UtilsPass2.endScope();})*
		('else'{UtilsPass2.beginScope();} NL statements{UtilsPass2.endScope();})?
		'end' NL
	;

stm_foreach:
		'foreach' name = ID 'in' expr NL
        {
            UtilsPass2.beginScope();
            UtilsPass2.putIterator($name.text, $expr.return_type, $name.getLine());
        }
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
		expr temp = NL {
            if($expr.return_type.toString().equals("notype"))
                UtilsPass2.print("Error " + $temp.getLine() + ") " + "Invalid Operatio");
        }
	;

expr returns [Type return_type, boolean lvalue = false]:
		temp = expr_assign
        {
            $return_type = $expr_assign.return_type;
            $lvalue = $temp.lvalue;
        }
	;

expr_assign returns [Type return_type, boolean lvalue = false]:
		temp = expr_or[true] temp2 = '=' expr_assign {
            mips.assignCommand();
            $return_type = UtilsPass2.generate_type($expr_or.return_type, $expr_assign.return_type);
            if(!$temp.lvalue)
                UtilsPass2.print("Error " + $temp2.getLine() + ") Rvalue assignment!");
        }
	|	expr_or[false] {
            $return_type = $expr_or.return_type;
            $lvalue = $expr_or.lvalue;
        }
	;

expr_or [boolean isLeft] returns [Type return_type, boolean lvalue = false]:
		expr_and[isLeft] expr_or_tmp
        {
            $return_type = UtilsPass2.generate_type($expr_and.return_type, $expr_or_tmp.return_type);
            $lvalue = $expr_and.lvalue && $expr_or_tmp.lvalue;
        }
	;

expr_or_tmp returns [Type return_type, boolean lvalue = false]:
		op='or' expr_and[false] expr_or_tmp
        {
             mips.operationCommand($op.text);
            $return_type = UtilsPass2.generate_type($expr_and.return_type, $expr_or_tmp.return_type);
        }
	|   {$return_type = null;$lvalue = true;}
	;

expr_and [boolean isLeft] returns [Type return_type, boolean lvalue = false]:
		expr_eq [isLeft] expr_and_tmp
        {
            $return_type = UtilsPass2.generate_type($expr_eq.return_type, $expr_and_tmp.return_type);
            $lvalue = $expr_eq.lvalue && $expr_and_tmp.lvalue;
        }
	;

expr_and_tmp returns [Type return_type, boolean lvalue = false]:
		op='and' expr_eq[false] expr_and_tmp
        {
             mips.operationCommand($op.text);
            $return_type = UtilsPass2.generate_type($expr_eq.return_type, $expr_and_tmp.return_type);
        }
	|   {$return_type = null;$lvalue = true;}
	;

expr_eq [boolean isLeft] returns [Type return_type, boolean lvalue = false]:
		expr_cmp[isLeft] expr_eq_tmp
        {
            $return_type = UtilsPass2.generate_type($expr_cmp.return_type, $expr_eq_tmp.return_type);
            $lvalue = $expr_cmp.lvalue && $expr_eq_tmp.lvalue;
        }
	;

expr_eq_tmp returns [Type return_type, boolean lvalue = false]:
		op=('==' | '<>') expr_cmp[false] expr_eq_tmp
        {
             mips.operationCommand($op.text);
            $return_type = UtilsPass2.generate_type($expr_cmp.return_type, $expr_eq_tmp.return_type);
        }
	|   {$return_type = null;$lvalue = true;}
	;

expr_cmp [boolean isLeft] returns [Type return_type, boolean lvalue = false]:
		expr_add [isLeft] expr_cmp_tmp
        {
            $return_type = UtilsPass2.generate_type($expr_add.return_type, $expr_cmp_tmp.return_type);
            $lvalue = $expr_add.lvalue && $expr_cmp_tmp.lvalue;
        }
	;

expr_cmp_tmp returns [Type return_type, boolean lvalue = false]:
		op=('<' | '>') expr_add[false] expr_cmp_tmp
        {
             mips.operationCommand($op.text);
            $return_type = UtilsPass2.generate_type($expr_add.return_type, $expr_cmp_tmp.return_type);
        }
	|   {$return_type = null;$lvalue = true;}
	;

expr_add [boolean isLeft] returns [Type return_type, boolean lvalue = false]:
		expr_mult[isLeft] expr_add_tmp
        {
            $return_type = UtilsPass2.generate_type($expr_mult.return_type, $expr_add_tmp.return_type);
            $lvalue = $expr_mult.lvalue && $expr_add_tmp.lvalue;
        }
	;

expr_add_tmp returns [Type return_type, boolean lvalue = false]:
		op=('+' | '-') expr_mult[false] expr_add_tmp
        {
             mips.operationCommand($op.text);
            $return_type = UtilsPass2.generate_type($expr_mult.return_type, $expr_add_tmp.return_type);
        }
	|   {$return_type = null; $lvalue = true;}
	;

expr_mult [boolean isLeft] returns [Type return_type, boolean lvalue = false]:
		expr_un [isLeft] expr_mult_tmp
        {
            $return_type = UtilsPass2.generate_type($expr_un.return_type, $expr_mult_tmp.return_type);
            $lvalue = $expr_un.lvalue && $expr_mult_tmp.lvalue;
        }
	;

expr_mult_tmp returns [Type return_type, boolean lvalue = false]:
		op=('*' | '/') expr_un[false] expr_mult_tmp
        {
             mips.operationCommand($op.text);
            $return_type = UtilsPass2.generate_type($expr_un.return_type, $expr_mult_tmp.return_type);
        }
	|   {$return_type = null; $lvalue = true;}
	;

expr_un [boolean isLeft] returns  [Type return_type, boolean lvalue = false]:
		op=('not' | '-') expr_un [isLeft] {
             mips.operationCommand($op.text);
            $return_type = $expr_un.return_type;
        }
	|	expr_mem [isLeft] {
            $return_type = $expr_mem.return_type;
            $lvalue = $expr_mem.lvalue;
        }
	;

expr_mem [boolean isLeft] returns [Type return_type, boolean lvalue = false]:
		expr_other [isLeft] expr_mem_tmp
        {
            $return_type = $expr_other.return_type.get_sub_array($expr_mem_tmp.dimension);
            $lvalue = $expr_other.lvalue;
        }
	;

expr_mem_tmp returns [int dimension]:
		'[' temp = expr temp2 = ']' expr_mem_tmp {
            if(!$temp.return_type.equals(IntType.getInstance()))
                UtilsPass2.print("Error " + $temp2.getLine() + ") invalid index!");
            else
                $dimension = $expr_mem_tmp.dimension + 1;
            }
	|    {$dimension = 0;}
	;

expr_other [boolean isLeft] returns [Type return_type, boolean lvalue = false]:
		num = CONST_NUM { $return_type =  IntType.getInstance(); mips.addToStack(Integer.parseInt($num.text)); }
	|	num = CONST_CHAR { $return_type =  CharType.getInstance(); }
	|	str = CONST_STR { $return_type = new ArrayType($str.text.length()-2,CharType.getInstance());}
	|	name = ID {
            SymbolTableVariableItemBase item = (SymbolTableVariableItemBase) UtilsPass2.def_check($name.text, $name.getLine());
            $return_type = item.getVariable().getType();
            $lvalue = UtilsPass2.setLvalueFlag($name.text);
            SymbolTableVariableItemBase var = (SymbolTableVariableItemBase) SymbolTable.top.get($name.text);
            if (var.getBaseRegister() == Register.SP){
                if ($isLeft == false) mips.addToStack($name.text, var.getOffset()*-1);
                else mips.addAddressToStack($name.text, var.getOffset()*-1);
            }
            else {
                if ($isLeft == false) mips.addGlobalToStack(var.getOffset());
                else mips.addGlobalAddressToStack($name.text, var.getOffset());
            }
        }
	|	{int counter = 0;}
        '{' temp = expr{counter++;} (k = ',' temp2 = expr{
            if(!$temp2.return_type.equals($temp.return_type)){
                UtilsPass2.print("Error " + $k.getLine() + ") types dont match!");
                counter = -1;
                $return_type = NoType.getInstance();
            }
            if(counter != -1)
                counter++;
            })* '}'{
                if(counter != -1)
                    $return_type = new ArrayType(counter, $temp.return_type);
            }
	|	'read' '(' size = CONST_NUM ')'{$return_type = new ArrayType($size.int, CharType.getInstance());}
	|	'(' expr ')' {$return_type = $expr.return_type;}
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
