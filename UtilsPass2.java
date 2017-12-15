import java.util.ArrayList;

public class UtilsPass2 {
    public static void print(String str){
        System.out.println(str);
    }

    public static void beginScope() {
        SymbolTable.push();
    }

    public static void endScope() {
        print("Stack offset: " + SymbolTable.top.getOffset(Register.SP) + ", Global offset: " + SymbolTable.top.getOffset(Register.GP));
        SymbolTable.pop();
    }
}
