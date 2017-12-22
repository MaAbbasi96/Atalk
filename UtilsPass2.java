import java.util.ArrayList;

public class UtilsPass2 {
    public static boolean init_with_no_args = false;

    public static void print(String str){
        System.out.println(str);
    }

    public static void beginScope() {
        SymbolTable.push();
    }

    public static void putItem(SymbolTableItem item) throws ItemAlreadyExistsException{
        SymbolTable.top.put(item);
    }

    public static void endScope() {
        print("Stack offset: " + SymbolTable.top.getOffset(Register.SP) + ", Global offset: " + SymbolTable.top.getOffset(Register.GP));
        SymbolTable.pop();
    }

    public static SymbolTableItem def_check(String name, int line){
        SymbolTableItem item = SymbolTable.top.get(name);
        if(item == null) {
            print("Error " + line + ") Undefined Reference. " + name + " doesn't exist.");
            try{
                item = new SymbolTableLocalVariableTempItem(new Variable(name, NoType.getInstance()),SymbolTable.top.getOffset(Register.SP));
                putItem(item);
            }
            catch(ItemAlreadyExistsException ex) {}
        }
        else {
            // print("" + item.getDefinitionNumber());
            SymbolTableVariableItemBase var = (SymbolTableVariableItemBase) item;
            print(line + ") Variable " + name + " used.\t\t" +   "Base Reg: " + var.getBaseRegister() + ", Offset: " + var.getOffset());
        }
        return item;
    }
    public static Type generate_type(Type exp1, Type exp2){
        Type res;
        if(exp1 == exp2 || exp2 == null)
            res = exp1;
        else
            res = NoType.getInstance();
        return res;
    }
    public static void tell_check(String actorName, String funcName, int line, ArrayList<String> args){
        SymbolTableItem item = SymbolTable.top.get(actorName);
        if(item == null && !actorName.equals("sender") && !actorName.equals("self"))
            print("Error " + line + ") Undefined Actor. Actor " + actorName + " doesn't exist.");
        if(actorName.equals("sender") && init_with_no_args == true)
            print("Error " + line + ") Cannot use sender inside init() with no arguments");
        else{
            print(line + ") Actor " + actorName + " used.");
            SymbolTable actorST;
            if(actorName.equals("self") || actorName.equals("sender"))
                actorST = SymbolTable.top;
            else
                actorST = ((SymbolTableActorItem) item).getActorSymbolTable();
            receiver_check(actorST, funcName, line, args);
        }
    }

    public static String make_str(String name, ArrayList<String> str){
        String res = name;
        for (String i: str)
            res += "#" + i;
        return res;
    }

    public static void receiver_check(SymbolTable symbolTable, String name, int line, ArrayList<String> args){
        String str_receiver = make_str(name, args);
        SymbolTableItem item = symbolTable.get(str_receiver);
        if(item == null)
            print("Error " + line + ") Undefined Receiver. Receiver " + name + " doesn't exist.");
        else
            print(line + ") Receiver " + name + " used.");
    }
}
