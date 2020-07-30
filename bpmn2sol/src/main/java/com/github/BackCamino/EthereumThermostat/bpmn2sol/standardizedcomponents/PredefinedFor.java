package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;

public class PredefinedFor extends For {
    public PredefinedFor(Value to) {
        super(
                new ValuedVariable("i", new Type(Type.BaseTypes.UINT), new Value("0")),
                new Condition("i < " + to.print()),
                new Statement("i++")
        );
    }
}
