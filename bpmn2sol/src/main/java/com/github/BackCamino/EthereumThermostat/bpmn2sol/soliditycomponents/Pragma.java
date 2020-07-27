package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Objects;

public class Pragma implements SolidityComponent {
    public enum Directives implements SolidityComponent {
        SOLIDITY,
        EXPERIMENTAL;

        @Override
        public String print() {
            return this.name().toLowerCase();
        }
    }

    private Directives directive;
    private String value;

    public Pragma(Directives directive, String value) {
        Objects.requireNonNull(directive);
        Objects.requireNonNull(value);
        this.directive = directive;
        this.value = value;
    }

    public Directives getDirective() {
        return directive;
    }

    public void setDirective(Directives directive) {
        this.directive = directive;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String print() {
        return "pragma " + directive.print() + " " + value + ";";
    }
}
