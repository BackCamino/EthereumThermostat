package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Objects;

public class Comment implements SolidityComponent {
    private String comment;

    public Comment(String comment) {
        Objects.requireNonNull(comment);
        this.comment = comment;
    }

    @Override
    public String print() {
        return "// " + this.comment;
    }
}
