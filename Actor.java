public class Actor {

	public Actor(String name, int box_size, SymbolTable symbolTable) {
		this.name = name;
		this.box_size = box_size;
		this.symbolTable = symbolTable;
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

	public SymbolTable getSymbolTable(){
        return symbolTable;
    }

	private String name;
	private int box_size;
	private SymbolTable symbolTable;
}
