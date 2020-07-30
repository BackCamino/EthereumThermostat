package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Objects;

public class Variable implements SolidityComponent {
    public enum Location {
        NONE,
        STORAGE,
        MEMORY,
        CALLDATA;

        public String print() {
            return this.equals(Location.NONE) ? "" : this.name().toLowerCase();
        }
    }

    private Location location;
    private String name;
    private Type type;
    private Visibility visibility;

    public Variable(String name, Type type, Visibility visibility, Location location) {
        Objects.requireNonNull(name);
        this.name = name;
        this.type = type;
        this.visibility = visibility;
        this.location = location;
    }

    public Variable(String name, Type type, Visibility visibility) {
        this(name, type, visibility, Location.NONE);
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

    public void setLocation(Location location) {
        this.location = location;
    }

    public Location getLocation() {
        return this.location;
    }

    @Override
    public String print() {
        return (this.type.print() + " "
                + this.visibility.print() + " "
                + (this.location.equals(Location.NONE) ? "" : (location.print() + " "))
                + this.name + ";")
                .replaceAll("  ", " ");
    }

    public Statement assignment(Value value) {
        return new Statement(this.getName() + " = " + value.getValue() + ";");
    }

    public Statement assignment(Variable variable) {
        return new Statement(this.getName() + " = " + variable.getName() + ";");
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Variable)) return false;
        Variable variable = (Variable) o;
        return name.equals(variable.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name);
    }
}