import java.util.ArrayList;
public class Receiver {

	public Receiver(String name, ArrayList<Variable> arguments) {
		this.name = name;
		this.arguments = arguments;
	}

	public String toString() {
        String key;
        key = name;
        for(int i = 0; i < arguments.size(); i++){
            key += "#";
            key += arguments.get(i).getType().toString();
        }
		return key;
	}

    public String getName(){
        return name;
    }

	public ArrayList<Variable> getArgs() {
		return arguments;
	}

	private String name;
	private ArrayList<Variable> arguments;
}
