public class SymbolTableLocalVariableTempItem extends SymbolTableVariableItemBase {
 public SymbolTableLocalVariableTempItem(Variable variable, int offset) {
  super(variable, offset);
 }

 public Register getBaseRegister() {
  return Register.SP;
 }

 @Override
 public boolean useMustBeComesAfterDef() {
  return false;
 }
}
