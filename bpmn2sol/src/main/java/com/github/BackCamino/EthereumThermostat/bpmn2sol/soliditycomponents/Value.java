package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Objects;

public class Value implements SolidityComponent {
    private Type type;
    private String value;

    public Value(Type type, String value) {
        this.type = type;
        this.value = value;
    }

    public Value(String value) {
        this(null, value);
    }

    public Type getType() {
        return type;
    }

    public String getValue() {
        return value;
    }

    @Override
    public String print() {
        return value;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Value)) return false;
        Value value1 = (Value) o;
        return type.equals(value1.type) &&
                value.equals(value1.value);
    }

    @Override
    public int hashCode() {
        return Objects.hash(type, value);
    }
}
