import java.util.*;
import java.io.*;
public class Variable {

	public Variable(String name, Type type) {
		this.name = name;
		this.type = type;
	}

	public ArrayList<Integer> getIndeces(){
		return type.getIndeces();
	}

	public String getName() {
		return name;
	}

	public Type getType() {
		return type;
	}

	public int size() {
		return type.size();
	}

	@Override
	public String toString() {
		return String.format("%s %s", type.toString(), name);
	}

	private String name;
	private Type type;
}
