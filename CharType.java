import java.util.*;
import java.io.*;
public class CharType extends Type {

	public int size() {
		return Type.CHAR_BYTES;
	}

	@Override
	public boolean equals(Object other) {
		if(other instanceof CharType)
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
	public String toString() {
		return "char";
	}

	private static CharType instance;

	@Override
	public Type get_sub_array(int x){
        return this;
    }

	@Override
	public int getSize(){
        return 1;
    }

	public static CharType getInstance() {
		if(instance == null)
			return instance = new CharType();
		return instance;
	}
}
