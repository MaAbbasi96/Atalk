import java.util.*;
import java.io.*;
public class IntType extends Type {

	public int size() {
		return Type.WORD_BYTES;
	}

	@Override
	public boolean equals(Object other) {
		if(other instanceof IntType)
			return true;
		return false;
	}

	@Override
    public ArrayList<Integer> getIndeces(){
        ArrayList<Integer> res = new ArrayList<>();
        res.add(0);
		return res;
    }

	@Override
	public boolean is_valid(){
        return true;
    }

	@Override
	public Type get_sub_array(int x){
        return this;
    }

	@Override
	public String toString() {
		return "int";
	}

	@Override
	public int getSize(){
        return 1;
    }

	private static IntType instance;

	public static IntType getInstance() {
		if(instance == null)
			return instance = new IntType();
		return instance;
	}
}
