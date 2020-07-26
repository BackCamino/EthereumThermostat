package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.LinkedList;
import java.util.List;

public class IfThenElse extends Statement {
    private Condition condition;
    private List<Statement> thenBranch;
    private List<Statement> elseBranch;

    public IfThenElse(Condition condition, List<Statement> thenBranch) {
        this(condition, thenBranch, List.of());
    }

    public IfThenElse(Condition condition, List<Statement> thenBranch, List<Statement> elseBranch) {
        super("if(" + condition.print() + ")");
        this.condition = condition;
        this.thenBranch = new LinkedList<>(thenBranch);
        this.elseBranch = new LinkedList<>(elseBranch);
    }

    @Override
    public String print() {
        StringBuilder toPrint = new StringBuilder("if(");
        toPrint.append(this.condition.print());
        toPrint.append(")");

        toPrint.append(thenBranch.size() > 1 ? " {\n" : "\n");
        this.thenBranch.stream()
                .map(el -> el.printWithIndentation(1) + "\n")
                .forEach(toPrint::append);
        if (thenBranch.size() > 1) toPrint.append("}\n");

        if (elseBranch.size() > 0) {
            toPrint.append("else ");
            toPrint.append(elseBranch.size() > 1 ? " {\n" : "\n");
            this.elseBranch.stream()
                    .map(el -> el.printWithIndentation(1) + "\n")
                    .forEach(toPrint::append);
            if (elseBranch.size() > 1) toPrint.append("}\n");
        }

        return toPrint.toString().trim();
    }
}
