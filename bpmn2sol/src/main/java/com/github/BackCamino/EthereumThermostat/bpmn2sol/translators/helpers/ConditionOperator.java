package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers;

import com.github.EmmanueleBollino.solcraft.soliditycomponents.*;

public class ConditionOperator {
    public ConditionOperator(Contract contract, String value) {
        this.contract = contract;
        this.value = value;
    }

    public Contract getContract() {
        return contract;
    }

    public String getValue() {
        return value;
    }

    private Contract contract;
    private String value;
}

