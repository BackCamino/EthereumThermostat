package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.LinkedList;
import java.util.List;
import java.util.stream.Stream;

class Event implements SolidityComponent, Invokable {
    private List<Variable> parameters;
    private String name;

    Event(String name, List<Variable> parameters) {
        this.name = name;
        this.parameters = new LinkedList<>(parameters);
    }

    Event(String name) {
        this(name, List.of());
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Variable> getParameters() {
        return parameters;
    }

    public void addParameter(Variable parameter) {
        this.parameters.add(parameter);
    }

    @Override
    public String print() {
        StringBuilder toPrint = new StringBuilder("event " + this.name + "(");
        this.parameters.forEach(el -> toPrint.append(el.getType() + " " + el.getName() + ", "));
        if (this.parameters.size() > 0)
            toPrint.delete(toPrint.length() - 3, toPrint.length() - 1);
        toPrint.append(");");

        return toPrint.toString();
    }

    @Override
    public String invocation(Value... values) {
        StringBuilder toPrint = new StringBuilder("emit " + this.name + "(");
        Stream.of(values).forEach(el -> toPrint.append(el.print() + ", "));
        if (values.length > 0)
            toPrint.delete(toPrint.length() - 3, toPrint.length() - 1);
        toPrint.append(");");

        return toPrint.toString();
    }
}