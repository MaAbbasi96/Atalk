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

	private static NoType instance;

	public static NoType getInstance() {
		if(instance == null)
			return instance = new NoType();
		return instance;
	}
}
