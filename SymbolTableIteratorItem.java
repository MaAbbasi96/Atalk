public class SymbolTableIteratorItem extends SymbolTableVariableItemBase {
 public SymbolTableIteratorItem(Variable variable, int offset) {
  super(variable, offset);
 }

 public Register getBaseRegister() {
  return Register.TEMP0;
 }

 @Override
 public boolean useMustBeComesAfterDef() {
  return false;
 }
}
