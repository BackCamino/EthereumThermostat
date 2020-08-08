package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.List;
import java.util.stream.Stream;

public class Constructor extends Operation implements StatementContainer {

    /**
     * @param name contract name
     */
    public Constructor(String name) {
        super(name);
    }

    public Constructor(String name, Visibility visibility, List<Variable> parameters, List<Statement> statements) {
        super(name, visibility, parameters, statements, false);
    }

    @Override
    public String print() {
        StringBuilder toPrint = new StringBuilder("constructor (");

        this.getParameters().forEach(el -> toPrint.append(el.getType() + " " + el.getName() + ", "));
        if (this.getParameters().size() > 0)
            toPrint.delete(toPrint.length() - 3, toPrint.length() - 1);
        toPrint.append(") " + this.getVisibility().print() + " {\n");
        this.getStatements().forEach(el -> toPrint.append(el.printWithIndentation(1) + "\n"));
        toPrint.append("}");

        return toPrint.toString();
    }

    @Override
    public String invocation(Value... values) {
        StringBuilder toPrint = new StringBuilder(this.getName());

        if (values.length == 0)
            return toPrint.toString();

        toPrint.append("(");
        Stream.of(values).forEach(el -> toPrint.append(el.print() + ", "));
        toPrint.delete(toPrint.length() - 3, toPrint.length() - 1).append(")");

        return toPrint.toString();
    }

    public static Constructor defaultConstructor(String name) {
        return new Constructor(name);
    }

    @Override
    public void setAbstract(boolean isAbstract) {
        // TODO consider allowing abstract constructors for abstract contracts
        if (isAbstract)
            throw new IllegalArgumentException("Constructor cannot be abstract");
    }
}
