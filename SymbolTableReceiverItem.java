public class SymbolTableReceiverItem extends SymbolTableItem {

	public SymbolTableReceiverItem(Receiver receiver) {
		this.receiver = receiver;
	}
	public Receiver getReceiver() {
		return receiver;
	}

	@Override
	public String getKey() {
		return receiver.toString();
	}

	Receiver receiver;
}
