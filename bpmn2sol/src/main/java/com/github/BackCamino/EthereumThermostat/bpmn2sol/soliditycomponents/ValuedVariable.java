package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public class ValuedVariable extends Variable {
    private Value value;

    public ValuedVariable(String name, Type type, Value value) {
        super(name, type);
        this.value = value;
    }

    public Value getValue() {
        return value;
    }

    public void setValue(Value value) {
        this.value = value;
    }

    public Statement assignment() {
        return super.assignment(this.value);
    }
}
