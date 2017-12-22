import java.util.ArrayList;

public class UtilsPass2 {
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
    public static void check_actor(String actorName, String funcName, int line){

    }
}
