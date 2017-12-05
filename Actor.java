public class Actor {

	public Actor(String name, int box_size) {
		this.name = name;
		this.box_size = box_size;
	}

	public String getName() {
		return name;
	}

	public int size() {
		return box_size;
	}

	@Override
	public String toString() {
		return String.format("%s %s", Integer.toString(box_size), name);
	}

	private String name;
	private int box_size;
}
