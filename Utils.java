import java.util.ArrayList;
// import sun.text.normalizer.SymbolTable;

public class Utils {
    public static boolean have_actor = false;
    public static int in_loop = 0;
    public static boolean have_error = false;
    public static String log;
    public static void print(String str){
        System.out.println(str);
    }
    public static void putItem(SymbolTableItem item) throws ItemAlreadyExistsException{
        SymbolTable.top.put(item);
    }
    public static void beginScope() {
    	int localOffset = 0;
    	int globalOffset = 0;

    	if(SymbolTable.top != null) {
        	localOffset = SymbolTable.top.getOffset(Register.SP);
        	globalOffset = SymbolTable.top.getOffset(Register.GP);
    	}

        SymbolTable.push(new SymbolTable(SymbolTable.top));

        SymbolTable.top.setOffset(Register.SP, localOffset);
        SymbolTable.top.setOffset(Register.GP, globalOffset);
    }

    public static void endScope() {
        log += "Stack offset: " + SymbolTable.top.getOffset(Register.SP) + " and Global offset: " + SymbolTable.top.getOffset(Register.GP) + "\n";
        if(SymbolTable.top.getPreSymbolTable() != null) {
            SymbolTable.top.getPreSymbolTable().setOffset(
                Register.GP,
                SymbolTable.top.getOffset(Register.GP)
            );
        }
        SymbolTable.pop();
    }

    public static void putLocalVar(ArrayList<String> name, Type type, int line){
        for(int i = 0; i < name.size(); i++){
            if(!type.is_valid())
                print(String.format("[Line #%s] Variable \"%s\" wrong size.", line, name.get(i)));
            try {
                putItem(new SymbolTableLocalVariableItem(new Variable(name.get(i), type),SymbolTable.top.getOffset(Register.SP)));
                log += "ID: " + name.get(i) + " with type: " + type + " and size: " + type.size() + " and Local offset: " + (SymbolTable.top.getOffset(Register.SP) - type.size()) + "\n";
            }
            catch(ItemAlreadyExistsException ex) {
                have_error = true;
                int counter = 1;
                print(String.format("[Line #%s] Variable \"%s\" already exists.", line, name.get(i)));
                while(true){
                    try{
                        putItem(new SymbolTableLocalVariableItem(new Variable(name.get(i) + "_temp_" + counter, type),SymbolTable.top.getOffset(Register.SP)));
                        break;
                    }
                    catch(ItemAlreadyExistsException ex1){
                        counter++;
                    }
                }
            }
        }
    }
    public static void putReciver(ArrayList<Variable> arguments, int line, String reciverName){
            String name = reciverName;
            try{
                putItem(new SymbolTableReceiverItem(new Receiver(reciverName, arguments)));
                log += "Receiver: " + reciverName + " with ";
                if(arguments.size() == 0)
                    log += "no arguments!!!";
                else
                    log += "with arguments: ";
                for(int i = 0; i < arguments.size(); i++)
                    log += arguments.get(i).toString() + ", ";
                log += "\n";
            }
            catch(ItemAlreadyExistsException ex) {
                have_error = true;
                print(String.format("[Line #%s] Receiver \"%s\" already exists.", line, reciverName));
                    int counter = 1;
                    have_error = true;
                    name += "_temp_";
                    while(true){
                        try{
                            putItem(new SymbolTableReceiverItem(new Receiver(reciverName + "_temp_" + counter, arguments)));
                            break;
                        }
                        catch(ItemAlreadyExistsException ex2) {
                            counter++;
                        }

                    }
            }
            finally{
                beginScope();
                for(int i = 0; i < arguments.size(); i++){
                    ArrayList<String> names = new ArrayList<>();
                    names.add(arguments.get(i).getName());
                    putLocalVar(names, arguments.get(i).getType(), line);
                }
            }
    }
    public static void putActor(String name, int box_size, int line){
        String firstName = name;
        if(box_size <= 0){
            box_size = 0;
            have_error = true;
        }
        try{
            putItem(new SymbolTableActorItem(new Actor(name, box_size)));
            log += "Actor: " + firstName + " with size: " + box_size + "\n";
        }
        catch(ItemAlreadyExistsException ex) {
            int counter = 1;
            have_error = true;
            print(String.format("[Line #%s] Actor \"%s\" already exists.", line, firstName));
            while(true){
                try{
                    putItem(new SymbolTableActorItem(new Actor(name + "_temp_" + counter, box_size)));
                    break;
                }
                catch(ItemAlreadyExistsException ex1){
                    counter++;
                }
            }
        }
    }


    public static void putGlobalVar(Type type, ArrayList<String> name, int line) {
        for(int i = 0; i < name.size(); i++){
            if(!type.is_valid())
                print(String.format("[Line #%s] Variable \"%s\" wrong size.", line, name.get(i)));
            try {
                putItem(new SymbolTableGlobalVariableItem(new Variable(name.get(i), type),SymbolTable.top.getOffset(Register.GP)));
                log += "ID: " + name.get(i) + " with type: " + type + " and size: " + type.size() + " and Global offset: " + (SymbolTable.top.getOffset(Register.GP) - type.size()) + "\n";
            }
            catch(ItemAlreadyExistsException ex) {
                have_error = true;
                int counter = 1;
                print(String.format("[Line #%s] Variable \"%s\" already exists.", line, name.get(i)));
                while(true){
                    try{
                        putItem(new SymbolTableGlobalVariableItem(new Variable(name + "_temp_" + counter, type),SymbolTable.top.getOffset(Register.GP)));
                        break;
                    }
                    catch(ItemAlreadyExistsException ex1){
                        counter++;
                    }
                }
            }
        }
    }
}
