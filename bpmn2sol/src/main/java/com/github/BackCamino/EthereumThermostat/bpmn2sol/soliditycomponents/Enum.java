package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.StringHelper;

import java.util.LinkedList;
import java.util.List;

public class Enum implements SolidityComponent {
    private String name;
    private List<Value> values;

    public Enum(String name, List<Value> values) {
        this.name = name;
        this.values = new LinkedList<>(values);
    }

    public Enum(String name) {
        this(name, List.of());
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Value> getValues() {
        return values;
    }

    public boolean addValue(Value value) {
        return this.values.add(value);
    }

    @Override
    public String print() {
        StringBuilder toPrint = new StringBuilder("enum ");
        toPrint.append(StringHelper.capitalize(this.name) + " {");
        values.stream()
                .map(Value::print)
                .map(String::toUpperCase)
                .map(Value::new)
                .map(el -> el.printWithIndentation(1) + ",\n")
                .forEach(toPrint::append);
        if (values.size() > 0) {
            toPrint.setLength(toPrint.length() - 2);
            toPrint.append("\n");
        }
        toPrint.append("}");

        return toPrint.toString();
    }
}
