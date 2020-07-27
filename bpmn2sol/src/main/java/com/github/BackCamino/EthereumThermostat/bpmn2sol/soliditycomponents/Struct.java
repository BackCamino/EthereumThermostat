package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.LinkedList;
import java.util.List;
import java.util.stream.Stream;

public class Struct extends Type implements SolidityComponent, Declarable, Invokable {
    private List<Variable> fields;

    public Struct(String type) {
        this(type, List.of());
    }

    public Struct(String type, List<Variable> fields) {
        super(type);
        fields.forEach(el -> el.setVisibility(Visibility.NONE));
        this.fields = new LinkedList<>(fields);
    }

    public void addField(Variable field) {
        field.setVisibility(Visibility.NONE);
        if (!this.fields.contains(field)) this.fields.add(field);
    }

    public void addField(Variable field, int index) {
        field.setVisibility(Visibility.NONE);
        if (!this.fields.contains(field)) this.fields.add(index, field);
    }

    public List<Variable> getFields() {
        return this.fields;
    }

    public boolean removeField(Variable field) {
        return this.fields.remove(field);
    }

    @Override
    public String declaration() {
        StringBuilder toPrint = new StringBuilder("struct " + this.print() + " {\n");
        this.fields.forEach(el -> toPrint.append(el.printWithIndentation(1) + "\n"));
        toPrint.append("}");

        return toPrint.toString();
    }

    @Override
    public String getName() {
        return this.print();
    }

    @Override
    public String invocation(Value... values) {
        StringBuilder toPrint = new StringBuilder(this.getName() + "(");
        Stream.of(values)
                .map(Value::print)
                .map(el -> el + ", ")
                .forEach(toPrint::append);
        if (values.length > 0)
            toPrint.setLength(toPrint.length() - 2);
        toPrint.append(")");

        return toPrint.toString();
    }
}
