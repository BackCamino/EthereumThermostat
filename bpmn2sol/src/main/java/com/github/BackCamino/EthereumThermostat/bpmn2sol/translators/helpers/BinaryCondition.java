package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers;

import com.github.EmmanueleBollino.solcraft.soliditycomponents.*;

public class BinaryCondition {
    public BinaryCondition(Contract applied, ConditionOperator first, String comparator, ConditionOperator second) {
        this.applied = applied;
        this.first = first;
        this.comparator = comparator;
        this.second = second;
    }

    public Contract getApplied() {
        return applied;
    }

    public ConditionOperator getFirst() {
        return first;
    }

    public String getComparator() {
        return comparator;
    }

    public ConditionOperator getSecond() {
        return second;
    }

    private Contract applied;
    private ConditionOperator first;
    private String comparator;
    private ConditionOperator second;
}
