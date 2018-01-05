import java.util.*;
import java.io.*;
public class NoType extends Type {

	@Override
	public boolean equals(Object other) {
		if(other instanceof NoType)
			return true;
		return false;
	}

	@Override
	public boolean is_valid(){
		return true;
	}

	@Override
    public ArrayList<Integer> getIndeces(){
        ArrayList<Integer> res = new ArrayList<>();
        res.add(0);
		return res;
    }

	@Override
	public String toString() {
		return "notype";
	}

	public int size() {
		return 0;
	}

	@Override
	public Type get_sub_array(int x){
		return this;
	}

	@Override
	public int getSize(){
        return 1;
    }

	private static NoType instance;

	public static NoType getInstance() {
		if(instance == null)
			return instance = new NoType();
		return instance;
	}
}
