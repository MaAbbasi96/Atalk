/**
 * Created by vrasa on 12/26/2016.
 */

import java.util.*;
import java.io.*;

public class Translator {

    private File output;
    private int labelCount;
    private ArrayList <String> instructions;
    private ArrayList <String> initInstructions;

    public String labelGenerator(){
        return "LABEL" + (labelCount++);
    }

    public Translator(){
        instructions = new ArrayList<String>();
        initInstructions = new ArrayList<String>();
        labelCount = 0;
        output = new File("out.asm");
        try {
            output.createNewFile();
        } catch (Exception e){
            e.printStackTrace();
        }
    }

    public void makeOutput(){
        this.addSystemCall(10);
        try {
            PrintWriter writer = new PrintWriter(output);
            writer.println("main:");
            writer.println("move $fp, $sp");
            for (int i=0;i<initInstructions.size();i++){
                writer.println(initInstructions.get(i));
            }
            for (int i=0;i<instructions.size();i++){
                writer.println(instructions.get(i));
            }
            writer.close();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public void addToStack(int x){
        instructions.add("# adding a number to stack");
        instructions.add("li $a0, " + x);
        instructions.add("sw $a0, 0($sp)");
        instructions.add("addiu $sp, $sp, -4");
        instructions.add("# end of adding a number to stack");

    }

    public String beginIf(){
        instructions.add("# start of if block");
        instructions.add("lw $a0, 4($sp)");
        popStack();
        String label = labelGenerator();
        instructions.add("beq $a0, $zero, " + label);
        instructions.add("# end of if block");
        return label;
    }

    public void addLabel(String label){
        instructions.add(label + ": ");
    }

    public void jumpTo(String label){
        instructions.add("j " + label);
    }

    public void addToStack(String s, int adr, ArrayList<Integer> indeces, int dimension){
//        int adr = table.getAddress(s)*(-1);
        instructions.add("# start of adding variable to stack");
        instructions.add("addiu $a0, $fp, " + adr );
        for(int i = 0; i < dimension; i++){
            instructions.add("lw $a1, 4($sp)");
            popStack();
            for(int j = 0; j < i; j++){
                instructions.add("li $a2, " + indeces.get(indeces.size()-j-1) * 4);
                instructions.add("mul $a1, $a1, $a2");
            }
            instructions.add("add $a0, $a0, $a1");
        }
        instructions.add("lw $a0, 0($a0)");
        instructions.add("sw $a0, 0($sp)");
        instructions.add("addiu $sp, $sp, -4");
        instructions.add("# end of adding variable to stack");
    }

    public void addAddressToStack(String s, int adr, ArrayList<Integer> indeces, int dimension) {
//        int adr = table.getAddress(s)*(-1);
        instructions.add("# start of adding address to stack");
        instructions.add("addiu $a0, $fp, " + adr );
        for(int i = 0; i < dimension; i++){
            instructions.add("lw $a1, 4($sp)");
            popStack();
            for(int j = 0; j < i; j++){
                instructions.add("li $a2, " + indeces.get(indeces.size()-j-1) * 4);
                instructions.add("mul $a1, $a1, $a2");
            }
            instructions.add("add $a0, $a0, $a1");
        }
        instructions.add("sw $a0, 0($sp)");
        instructions.add("addiu $sp, $sp, -4");
        instructions.add("# end of adding address to stack");
    }

    public void addGlobalAddressToStack(String s, int adr, ArrayList<Integer> indeces, int dimension){
//        int adr = table.getAddress(s)*(-1);
        instructions.add("# start of adding global address to stack");
        instructions.add("addiu $a0, $gp, " + adr);
        for(int i = 0; i < dimension; i++){
            instructions.add("lw $a1, 4($sp)");
            popStack();
            for(int j = 0; j < i; j++){
                instructions.add("li $a2, " + indeces.get(indeces.size()-j-1) * 4);
                instructions.add("mul $a1, $a1, $a2");
            }
            instructions.add("add $a0, $a0, $a1");
        }
        instructions.add("sw $a0, 0($sp)");
        instructions.add("addiu $sp, $sp, -4");
        instructions.add("# end of adding global address to stack");
    }

    public void popStack(){
        instructions.add("# pop stack");
        instructions.add("addiu $sp, $sp, 4");
        instructions.add("# end of pop stack");
    }

    public void addSystemCall(int x){
        instructions.add("# start syscall " + x);
        instructions.add("li $v0, " + x);
        instructions.add("syscall");
        instructions.add("# end syscall");
    }

    public void assignCommand(){
        instructions.add("# start of assign");
        instructions.add("lw $a0, 4($sp)");
        popStack();
        instructions.add("lw $a1, 4($sp)");
        popStack();
        instructions.add("sw $a0, 0($a1)");
        instructions.add("sw $a0, 0($sp)");
        instructions.add("addiu $sp, $sp, -4");
        instructions.add("# end of assign");
    }

    public void operationCommand(String s){
        instructions.add("# operation " + s);
        if (s.equals("*")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("lw $a1, 4($sp)");
            popStack();
            instructions.add("mul $a0, $a0, $a1");
            instructions.add("sw $a0, 0($sp)");
            instructions.add("addiu $sp, $sp, -4");
        }
        else if (s.equals("/")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("lw $a1, 4($sp)");
            popStack();
            instructions.add("div $a0, $a1, $a0");
            instructions.add("sw $a0, 0($sp)");
            instructions.add("addiu $sp, $sp, -4");
        }
        else if (s.equals("+")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("lw $a1, 4($sp)");
            popStack();
            instructions.add("add $a0, $a0, $a1");
            instructions.add("sw $a0, 0($sp)");
            instructions.add("addiu $sp, $sp, -4");
        }
        else if (s.equals("-")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("lw $a1, 4($sp)");
            popStack();
            instructions.add("sub $a0, $a1, $a0");
            instructions.add("sw $a0, 0($sp)");
            instructions.add("addiu $sp, $sp, -4");
        }
        else if (s.equals("or")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("lw $a1, 4($sp)");
            popStack();
            instructions.add("or $a0, $a1, $a0");
            instructions.add("sw $a0, 0($sp)");
            instructions.add("addiu $sp, $sp, -4");
        }
        else if (s.equals("and")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("lw $a1, 4($sp)");
            popStack();
            instructions.add("and $a0, $a1, $a0");
            instructions.add("sw $a0, 0($sp)");
            instructions.add("addiu $sp, $sp, -4");
        }
        else if (s.equals("==")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("lw $a1, 4($sp)");
            popStack();
            String label1 = labelGenerator();
            String label2 = labelGenerator();
            instructions.add("beq $a0, $a1, " + label1);
            instructions.add("sw $zero, 0($sp)");
            instructions.add("j " + label2);
            instructions.add(label1 + ": addiu $a0, $zero, 1");
            instructions.add("sw $a0, 0($sp)");
            instructions.add(label2 + ": addiu $sp, $sp, -4");
        }
        else if (s.equals("<>")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("lw $a1, 4($sp)");
            popStack();
            String label1 = labelGenerator();
            String label2 = labelGenerator();
            instructions.add("bne $a0, $a1, " + label1);
            instructions.add("sw $zero, 0($sp)");
            instructions.add("j " + label2);
            instructions.add(label1 + ": addiu $a0, $zero, 1");
            instructions.add("sw $a0, 0($sp)");
            instructions.add(label2 + ": addiu $sp, $sp, -4");
        }
        else if (s.equals(">")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("lw $a1, 4($sp)");
            popStack();
            String label1 = labelGenerator();
            String label2 = labelGenerator();
            instructions.add("blt $a0, $a1, " + label1);
            instructions.add("sw $zero, 0($sp)");
            instructions.add("j " + label2);
            instructions.add(label1 + ": addiu $a0, $zero, 1");
            instructions.add("sw $a0, 0($sp)");
            instructions.add(label2 + ": addiu $sp, $sp, -4");
        }
        else if (s.equals("<")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("lw $a1, 4($sp)");
            popStack();
            String label1 = labelGenerator();
            String label2 = labelGenerator();
            instructions.add("bgt $a0, $a1, " + label1);
            instructions.add("sw $zero, 0($sp)");
            instructions.add("j " + label2);
            instructions.add(label1 + ": addiu $a0, $zero, 1");
            instructions.add("sw $a0, 0($sp)");
            instructions.add(label2 + ": addiu $sp, $sp, -4");
        }
        else if (s.equals("not")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("not $a0, $a0");
            instructions.add("sw $a0, 0($sp)");
            instructions.add("addiu $sp, $sp, -4");
        }
        else if (s.equals("--")){
            instructions.add("lw $a0, 4($sp)");
            popStack();
            instructions.add("sub $a0, $zero, $a0");
            instructions.add("sw $a0, 0($sp)");
            instructions.add("addiu $sp, $sp, -4");
        }
        instructions.add("# end of operation " + s);
    }

    public void write(String type){
        instructions.add("# writing");
        instructions.add("lw $a0, 4($sp)");
        if(type.equals("int"))
            this.addSystemCall(1);
        else if(type.equals("char"))
            this.addSystemCall(11);
        popStack();
        instructions.add("addi $a0, $zero, 10");
        this.addSystemCall(11);
        instructions.add("# end of writing");
    }

    public void addGlobalToStack(int adr, ArrayList<Integer> indeces, int dimension){
//        int adr = table.getAddress(s)*(-1);
        instructions.add("# start of adding global variable to stack");
        instructions.add("addiu $a0, $gp, " + adr);
        for(int i = 0; i < dimension; i++){
            instructions.add("lw $a1, 4($sp)");
            popStack();
            for(int j = 0; j < i; j++){
                instructions.add("li $a2, " + indeces.get(indeces.size()-j-1) * 4);
                instructions.add("mul $a1, $a1, $a2");
            }
            instructions.add("add $a0, $a0, $a1");
        }
        instructions.add("lw $a0, 0($a0)");
        instructions.add("sw $a0, 0($sp)");
        instructions.add("addiu $sp, $sp, -4");
        instructions.add("# end of adding global variable to stack");
    }

    public void addGlobalVariable(int adr, int x){
//        int adr = table.getAddress(s)*(-1);
        initInstructions.add("# adding a global variable");
        initInstructions.add("li $a0, " + x);
        initInstructions.add("sw $a0, " + adr + "($gp)");
        initInstructions.add("# end of adding a global variable");
    }
}
