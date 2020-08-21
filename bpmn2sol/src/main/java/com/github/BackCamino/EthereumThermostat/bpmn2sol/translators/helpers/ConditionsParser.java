package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers;

import com.github.EmmanueleBollino.solcraft.soliditycomponents.*;
import org.camunda.bpm.model.bpmn.instance.SequenceFlow;

import java.util.Collection;

public class ConditionsParser {
    public static BinaryCondition parseCondition(String condition, Collection<Contract> contracts) {
        String[] parts = condition.split("\\(");
        String[] finalParts = parts;
        Contract applied = findContract(contracts, finalParts[0]);
        parts = parts[1].replace(")", "").trim().split(" ");
        ConditionOperator first;
        ConditionOperator second;

        String[] operatorParts = parts[0].split("\\.");
        if (operatorParts.length == 1) {
            first = new ConditionOperator(null, parts[0].trim());
        } else {
            first = new ConditionOperator(findContract(contracts, operatorParts[0]), operatorParts[1].trim());
        }

        operatorParts = parts[2].split("\\.");
        if (operatorParts.length == 1) {
            second = new ConditionOperator(null, parts[2].trim());
        } else {
            second = new ConditionOperator(findContract(contracts, operatorParts[0]), operatorParts[1].trim());
        }

        return new BinaryCondition(applied, first, parts[1].trim(), second);
    }

    private static Contract findContract(Collection<Contract> contracts, String name) {
        return contracts.stream().filter(el -> el.getName().equals(name.trim())).findAny().orElseThrow();
    }

    public static BinaryCondition parseCondition(SequenceFlow flow, Collection<Contract> contracts) {
        return parseCondition(flow.getName(), contracts);
    }
}
