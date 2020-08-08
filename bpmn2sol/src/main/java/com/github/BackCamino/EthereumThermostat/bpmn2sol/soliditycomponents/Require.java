package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public class Require extends Statement {
    private Condition condition;
    private String errorMessage;

    public Require(Condition condition, String errorMessage) {
        super("require(" + condition.print() + ", \"" + errorMessage + "\");");
        this.condition = condition;
        this.errorMessage = errorMessage;
    }

    public Require(Condition condition) {
        this(condition, "Error!");
    }

    public Condition getCondition() {
        return condition;
    }

    public String getErrorMessage() {
        return errorMessage;
    }
}
