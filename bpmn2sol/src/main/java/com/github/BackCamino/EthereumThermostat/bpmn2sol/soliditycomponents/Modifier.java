package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.List;
import java.util.stream.Stream;

class Modifier extends Operation implements SolidityComponent {
    class SpecialUnderscore extends Statement {
        public SpecialUnderscore() {
            super("_;");
        }

        @Override
        public boolean equals(Object obj) {
            if (obj instanceof Statement) {
                if (((Statement) obj).print().equals("_;"))
                    return true;
            }
            return false;
        }
    }

    public Modifier(String name, Visibility visibility, List<Variable> parameters, List<Statement> statements, boolean isAbstract) {
        super(name, visibility, parameters, statements, isAbstract);
    }

    public Modifier(String name) {
        super(name);
    }

    @Override
    public String print() {
        StringBuilder toPrint = new StringBuilder("modifier " + this.getName() + "(");
        this.getParameters().forEach(el -> toPrint.append(el.getType() + " " + el.getName() + ", "));
        if (this.getParameters().size() > 0)
            toPrint.delete(toPrint.length() - 3, toPrint.length() - 1);
        toPrint.append(") ");
        if (this.isAbstract()) toPrint.append("virtual ");
        toPrint.append("{");
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
        toPrint.append(")");

        return toPrint.toString();
    }
}