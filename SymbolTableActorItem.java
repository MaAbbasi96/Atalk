public class SymbolTableActorItem extends SymbolTableItem {

	public SymbolTableActorItem(Actor actor) {
		this.actor = actor;
	}
	public Actor getActor() {
		return actor;
	}

	@Override
	public String getKey() {
		return actor.getName();
	}

	public SymbolTable getActorSymbolTable(){
		return actor.getSymbolTable();
	}

	Actor actor;
}
