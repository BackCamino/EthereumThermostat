package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public class Variable implements SolidityComponent {
    private String name;
    private Type type;
    private Visibility visibility;

    public Variable(String name, Type type, Visibility visibility) {
        this.name = name;
        this.type = type;
        this.visibility = visibility;
    }

    public Variable(String name, Type type) {
        this(name, type, Visibility.PUBLIC);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Type getType() {
        return type;
    }

    public void setType(Type type) {
        this.type = type;
    }

    public Visibility getVisibility() {
        return visibility;
    }

    public void setVisibility(Visibility visibility) {
        this.visibility = visibility;
    }

    @Override
    public String print() {
        return this.type.print() + " " + this.name + ";";
    }

    public String assignment(Value value) {
        return this.getName() + " = " + value.getValue() + ";";
    }
}