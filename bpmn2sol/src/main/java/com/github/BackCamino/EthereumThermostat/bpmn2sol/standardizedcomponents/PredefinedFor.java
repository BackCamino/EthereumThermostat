package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;

import java.util.List;

public class PredefinedFor extends For {
    public PredefinedFor(Value to) {
        this(to, List.of());
    }

    public PredefinedFor(Value to, List<Statement> statements) {
        super(
                new ValuedVariable("i", new Type(Type.BaseTypes.UINT), new Value("0")),
                new Condition("i < " + to.print()),
                new Statement("i++"),
                statements
        );
    }
}
