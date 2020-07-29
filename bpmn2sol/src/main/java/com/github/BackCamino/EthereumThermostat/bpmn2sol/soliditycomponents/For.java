package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.LinkedList;
import java.util.List;

public class For extends Statement {
    private ValuedVariable start;
    private Condition condition;
    private Statement increment;
    private List<Statement> statements;

    public For(ValuedVariable start, Condition condition, Statement increment) {
        this(start, condition, increment, List.of());
    }

    public For(ValuedVariable start, Condition condition, Statement increment, List<Statement> statements) {
        super("for(" + start.getType().print() + " " + start.getName() + " = " + start.getValue().print() + "; " + condition.print() + "; " + increment.print() + ")");
        this.start = start;
        this.condition = condition;
        this.increment = increment;
        this.statements = new LinkedList<>(statements);
    }

    public void addStatement(Statement statement) {
        this.statements.add(statement);
    }

    @Override
    public String print() {
        StringBuilder toPrint = new StringBuilder(super.print());

        toPrint.append(statements.size() > 1 ? " {\n" : "\n");
        statements.stream()
                .map(el -> el.printWithIndentation(1) + "\n")
                .forEach(toPrint::append);
        if (statements.size() > 1) toPrint.append("}");

        return toPrint.toString().trim();
    }
}
