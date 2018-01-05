import java.util.ArrayList;

public class ArrayType extends Type {

    public ArrayType(int size, Type tail){
        this.size = size;
        this.tail = tail;
    }

	public int size() {
		return size * tail.size();
	}

    @Override
    public ArrayList<Integer> getIndeces(){
        ArrayList<Integer> res = new ArrayList<>();
        res.add(size);
        Type temp = get_sub_array(0);
        while(temp instanceof ArrayType){
            temp = get_sub_array(1);
            res.add(temp.getSize());
        }
        return res;
    }

    @Override
	public int getSize(){
        return this.size;
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

    @Override
    public Type get_sub_array(int x){
        if(x == 0)
            return this;
        else
            return tail.get_sub_array(x - 1);
    }

    private int size;
    private Type tail;

}
