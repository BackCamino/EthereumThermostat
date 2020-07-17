package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Objects;

public class Statement implements SolidityComponent {
    private String statement;

    public Statement(String statement) {
        this.statement = statement;
    }

    public String print() {
        return statement;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Statement)) return false;
        Statement statement1 = (Statement) o;
        return statement.equals(statement1.statement);
    }

    @Override
    public int hashCode() {
        return Objects.hash(statement);
    }
}
