package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.LinkedList;
import java.util.List;
import java.util.Objects;

public abstract class Operation implements SolidityComponent, Invokable {
    private String name;
    private Visibility visibility;
    private List<Variable> parameters;
    private List<Statement> statements;
    private boolean isAbstract;
    // TODO add ovverride

    public Operation(String name, Visibility visibility, List<Variable> parameters, List<Statement> statements,
                     boolean isAbstract) {
        this.name = name;
        this.visibility = visibility;
        this.parameters = new LinkedList<>();
        parameters.forEach(this::addParameter);
        this.statements = new LinkedList<>(statements);
        this.setAbstract(isAbstract);
    }

    public Operation(String name) {
        this(name, Visibility.PUBLIC, List.of(), List.of(), false);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Visibility getVisibility() {
        return visibility;
    }

    public void setVisibility(Visibility visibility) {
        this.visibility = visibility;
    }

    public List<Variable> getParameters() {
        return parameters;
    }

    public void addParameter(Variable parameter) {
        if (!parameter.getName().startsWith("_", 0))
            parameter.setName("_" + parameter.getName());
        this.parameters.add(parameter);
    }

    public List<Statement> getStatements() {
        return statements;
    }

    public void addStatement(Statement statement) {
        this.statements.add(statement);
    }

    public void addStatement(int index, Statement statement) {
        this.statements.add(index, statement);
    }

    public boolean isAbstract() {
        return isAbstract;
    }

    public void setAbstract(boolean isAbstract) {
        this.isAbstract = isAbstract;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Operation operation = (Operation) o;
        return name.equals(operation.name) &&
                parameters.equals(operation.parameters);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, parameters);
    }
}
