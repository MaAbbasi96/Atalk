public class ArrayType extends Type {

    public ArrayType(int size, Type tail){
        this.size = size;
        this.tail = tail;
    }

	public int size() {
		return size * tail.size();
	}

    @Override
    public boolean is_valid(){
        if(size <= 0 || !tail.is_valid()){
            if(size <= 0)
                size = 0;
            return false;
        }
        return true;
    }

	@Override
	public boolean equals(Object other) {
		if(other instanceof ArrayType)
			return true;
		return false;
	}

	@Override
	public String toString() {
		return "array";
	}

    private int size;
    private Type tail;

}
