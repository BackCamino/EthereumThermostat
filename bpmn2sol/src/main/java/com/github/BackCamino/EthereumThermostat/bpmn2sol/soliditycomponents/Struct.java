package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

public class Struct extends Type implements SolidityComponent {
    private Collection<Variable> fields;

    public Struct(String type) {
        this(type, Set.of());
    }

    public Struct(String type, Collection<Variable> fields) {
        super(type);
        this.fields = new HashSet<>(fields);
    }

    public void addField(Variable field) {
        this.fields.add(field);
    }

    public Collection<Variable> getFields() {
        return this.fields;
    }

    public boolean removeField(Variable field) {
        return this.fields.remove(field);
    }

    public String declaration() {
        StringBuilder toPrint = new StringBuilder("struct " + this.print() + " {\n");
        this.fields.forEach(el -> toPrint.append(el.printWithIndentation(1) + ",\n"));
        toPrint.append("}");

        return toPrint.toString();
    }
}
