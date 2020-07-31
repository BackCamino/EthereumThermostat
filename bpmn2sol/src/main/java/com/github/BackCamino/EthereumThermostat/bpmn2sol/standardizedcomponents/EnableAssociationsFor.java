package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Condition;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.IfThenElse;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Statement;

import java.util.List;

public class EnableAssociationsFor extends AssociationsFor {
    private IsAssociationEnabledIf isAssociationEnabledIf;
    private boolean requireEnabled;

    public class IsAssociationEnabledIf extends IfThenElse {
        public IsAssociationEnabledIf(String toCheck) {
            super(new Condition("isEnabled(" + toCheck + ", associations[i])"),
                    List.of());
        }
    }

    public EnableAssociationsFor(String toCheck, boolean requireEnabled) {
        this.isAssociationEnabledIf = new IsAssociationEnabledIf(toCheck);
        this.isAssociationEnabledIf.addThenStatement(new Statement("_enabled = true;"));
        this.addStatement(this.isAssociationEnabledIf);
        this.requireEnabled = requireEnabled;
        this.addDeactivation(toCheck);
    }

    public EnableAssociationsFor(String toCheck, String toEnable, boolean requireEnabled) {
        this(toCheck, requireEnabled);
        this.addActivation(toEnable);
    }

    public EnableAssociationsFor(String toCheck, String toEnable) {
        this(toCheck, toEnable, false);
    }

    public EnableAssociationsFor(String toCheck) {
        this(toCheck, false);
    }

    public void addActivation(String toEnable) {
        this.addStatementInIf(new Statement("enable(" + toEnable + ", associations[i]);"));
    }

    public void addDeactivation(String toDisable) {
        this.addStatementInIf(new Statement("disable(" + toDisable + ", associations[i]);"));
    }

    public void addStatementInIf(Statement statement) {
        this.isAssociationEnabledIf.addThenStatement(statement);
    }

    @Override
    public String print() {
        StringBuilder toPrint = new StringBuilder();
        toPrint.append(super.print());
        if (requireEnabled)
            toPrint.append("\nrequire(_enabled, \"Not Enabled\");");

        return toPrint.toString();
    }
}
