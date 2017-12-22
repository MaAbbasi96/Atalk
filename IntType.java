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

	private static IntType instance;

	public static IntType getInstance() {
		if(instance == null)
			return instance = new IntType();
		return instance;
	}
}
