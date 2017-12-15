import java.util.ArrayList;

public class Utils {
    public static boolean have_actor = false;
    public static int in_loop = 0;
    public static boolean have_error = false;
    public static String log;
    public static void print(String str){
        System.out.println(str);
    }
    public static void beginScope() {
        int offset = 0;
        if(SymbolTable.top != null)
            offset = SymbolTable.top.getOffset(Register.SP);
        SymbolTable.push(new SymbolTable(SymbolTable.top));
        SymbolTable.top.setOffset(Register.SP, offset);
    }
    public static void putLocalVar(String name, Type type) throws ItemAlreadyExistsException, InvalidArgumentException {
        if(!type.is_valid())
            throw new InvalidArgumentException();
        SymbolTable.top.put(
            new SymbolTableLocalVariableItem(
                new Variable(name, type),
                SymbolTable.top.getOffset(Register.SP)
            )
        );
    }
    public static void putGlobalVar(String name, Type type) throws ItemAlreadyExistsException, InvalidArgumentException {
        if(!type.is_valid())
            throw new InvalidArgumentException();
        SymbolTable.top.put(
            new SymbolTableGlobalVariableItem(
                new Variable(name, type),
                SymbolTable.top.getOffset(Register.GP)
            )
        );
    }
    public static void putActor(String name, int box_size) throws ItemAlreadyExistsException, InvalidArgumentException {
        if(box_size <= 0)
            throw new InvalidArgumentException();
        SymbolTable.top.put(
            new SymbolTableActorItem(
                new Actor(name, box_size)
            )
        );
    }
    public static void putReceiver(String name, ArrayList<Variable> arguments) throws ItemAlreadyExistsException {
        SymbolTable.top.put(
            new SymbolTableReceiverItem(
                new Receiver(name, arguments)
            )
        );
    }
    public static void endScope() {
         log += "Stack offset: " + SymbolTable.top.getOffset(Register.SP) + " and Global offset: " + SymbolTable.top.getOffset(Register.GP) + "\n";
         SymbolTable.pop();
    }
}
