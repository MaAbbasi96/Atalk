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

	private static NoType instance;

	public static NoType getInstance() {
		if(instance == null)
			return instance = new NoType();
		return instance;
	}
}
