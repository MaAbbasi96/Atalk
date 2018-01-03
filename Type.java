public abstract class Type {

	public abstract int size();

	public abstract boolean equals(Object other);

	public abstract String toString();

	public abstract boolean is_valid();

	public abstract Type get_sub_array(int x);

	public static final int WORD_BYTES = 4;
	public static final int CHAR_BYTES = 4;
}
