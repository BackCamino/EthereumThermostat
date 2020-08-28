package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.EmmanueleBollino.solcraft.soliditycomponents.*;

import java.util.List;

public class EnableAssociationsFor extends AssociationsFor {
    private IsAssociationEnabledIf isAssociationEnabledIf;
    private FirstEnabledIf firstEnabledIf;
    private boolean requireEnabled;

    public class IsAssociationEnabledIf extends IfThenElse {
        public IsAssociationEnabledIf(String toCheck) {
            super(new Condition("isEnabled(" + toCheck + ", associations[i])"),
                    List.of());
        }
    }

    public class FirstEnabledIf extends IfThenElse {
        public FirstEnabledIf() {
            super(new Condition("!_enabled"), List.of());
        }
    }

    public static class EnabledCycleRequire extends Require {
        public EnabledCycleRequire() {
            super(new Condition("_enabled"), "Not enabled");
        }
    }

    public static class IsEnabledDeclaration extends Statement {
        public IsEnabledDeclaration() {
            super("bool _enabled = false;");
        }
    }

    public EnableAssociationsFor(String toCheck, boolean requireEnabled) {
        this.isAssociationEnabledIf = new IsAssociationEnabledIf(toCheck);
        this.firstEnabledIf = new FirstEnabledIf();
        this.isAssociationEnabledIf.addStatement(firstEnabledIf);
        this.firstEnabledIf.addThenStatement(new Statement("_enabled = true;"));
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

    public FirstEnabledIf getFirstEnabledIf() {
        return firstEnabledIf;
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
