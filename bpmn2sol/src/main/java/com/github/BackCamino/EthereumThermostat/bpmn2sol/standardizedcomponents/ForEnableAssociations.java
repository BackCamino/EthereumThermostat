package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;

import java.util.List;

public class ForEnableAssociations extends For {
    private boolean requireEnabled;

    public ForEnableAssociations(String toCheck, boolean requireEnabled) {
        super(new ValuedVariable("i", new Type(Type.BaseTypes.UINT), new Value("0")),
                new Condition("i < associations.length"),
                new Statement("i++"),
                List.of(
                        new IfThenElse(
                                new Condition("isEnabled(" + toCheck + ", associations[i])"),
                                List.of(
                                        new Statement("_enabled = true;")
                                )
                        )
                ));
        this.requireEnabled = requireEnabled;
        this.addDeactivation(toCheck);
    }

    public ForEnableAssociations(String toCheck, String toEnable, boolean requireEnabled) {
        this(toCheck, requireEnabled);
        this.addActivation(toEnable);
    }

    public ForEnableAssociations(String toCheck, String toEnable) {
        this(toCheck, toEnable, false);
    }

    public ForEnableAssociations(String toCheck) {
        this(toCheck, false);
    }

    public void addActivation(String toEnable) {
        this.addStatement(new Statement("enable(" + toEnable + ", associations[i]);"));
    }

    public void addDeactivation(String toDisable) {
        this.addStatement(new Statement("disable(" + toDisable + ", associations[i]);"));
    }

    @Override
    public String print() {
        StringBuilder toPrint = new StringBuilder();
        toPrint.append("bool _enabled = false;\n");
        toPrint.append(super.print());
        if (requireEnabled)
            toPrint.append("\nrequire(_enabled, \"Not Enabled\");");

        return toPrint.toString();
    }
}
