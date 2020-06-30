package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

class Function extends Operation {
    private List<Variable> returned;
    private Map<Modifier, List<Value>> modifiers;
    private Markers marker;
    //TODO add override

    public enum Markers implements SolidityComponent {
        PURE,
        VIEW,
        PAYABLE;

        @Override
        public String print() {
            return this.name().toLowerCase();
        }
    }

    public Function(String name, Visibility visibility, List<Variable> parameters, List<Statement> statements, boolean isAbstract, List<Variable> returned, Markers marker) {
        super(name, visibility, parameters, statements, isAbstract);
        this.returned = new LinkedList<>(returned);
        this.marker = marker;
        this.modifiers = new HashMap<>();
    }

    public Function(String name) {
        super(name);
        this.returned = new LinkedList<>();
        this.modifiers = new HashMap<>();
    }

    public void addModifier(Modifier modifier, Value... values) {
        this.modifiers.put(modifier, List.of(values));
    }

    public void addModifier(Modifier modifier, List values) {
        this.modifiers.put(modifier, new LinkedList<>(values));
    }

    public void addReturned(Variable returned) {
        this.returned.add(returned);
    }

    public List<Variable> getReturned() {
        return returned;
    }

    public Map<Modifier, List<Value>> getModifiers() {
        return modifiers;
    }

    public Markers getMarker() {
        return marker;
    }

    public void setMarker(Markers marker) {
        this.marker = marker;
    }

    @Override
    public String print() {
        StringBuilder toPrint = new StringBuilder("function " + this.getName() + "(");
        this.getParameters().forEach(el -> toPrint.append(el.getType().print() + " " + el.getName() + ", "));
        if (this.getParameters().size() > 0)
            toPrint.delete(toPrint.length() - 3, toPrint.length() - 1);
        toPrint
                .append(") ")
                .append(this.getVisibility().print())
                .append(this.isAbstract() ? " virtual " : " ")
                .append(this.marker == null ? "" : (this.marker.print() + " "));
        if (this.returned.size() > 0) {
            toPrint.append("returns(");
            returned.forEach(el -> toPrint.append(el.getType().print() + " " + el.getName() + ", "));
            toPrint.delete(toPrint.length() - 3, toPrint.length() - 1).append(") ");
        }
        toPrint.append("{\n");
        this.getStatements().forEach(el -> toPrint.append(el.printWithIndentation(1) + "\n"));
        toPrint.append("}");

        return toPrint.toString();
    }

    @Override
    public String invocation(Value... values) {
        StringBuilder toPrint = new StringBuilder(this.getName() + "(");
        Stream.of(values).forEach(el -> toPrint.append(el.print() + ", "));
        if (values.length > 0)
            toPrint.delete(toPrint.length() - 3, toPrint.length() - 1);
        toPrint.append(");");
        return toPrint.toString();
    }
}