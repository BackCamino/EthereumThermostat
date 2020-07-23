package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Objects;

public class Type implements SolidityComponent {
    private String type;

    public Type(BaseTypes type) {
        this.type = type.print();
    }

    public Type(Extendable type) {
        this.type = type.print();
    }

    public Type(String type) {
        this.type = type;
    }

    public enum BaseTypes implements SolidityComponent {
        INT, UINT, ADDRESS, STRING, BOOL;

        public String print() {
            return this.name().toLowerCase();
        }
    }

    public String print() {
        return type;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Type)) return false;
        Type type1 = (Type) o;
        return type.equals(type1.type);
    }

    @Override
    public int hashCode() {
        return Objects.hash(type);
    }
}
