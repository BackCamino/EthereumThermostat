package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public class Mapping extends Type implements SolidityComponent {
    private Type keyType;
    private Type valueType;

    public Mapping(Type keyType, Type valueType) {
        super("mapping(" + keyType.print() + " => " + valueType.print() + ")");
        this.keyType = keyType;
        this.valueType = valueType;
    }

    public Type getKeyType() {
        return keyType;
    }

    public void setKeyType(Type keyType) {
        this.keyType = keyType;
    }

    public Type getValueType() {
        return valueType;
    }

    public void setValueType(Type valueType) {
        this.valueType = valueType;
    }
}
