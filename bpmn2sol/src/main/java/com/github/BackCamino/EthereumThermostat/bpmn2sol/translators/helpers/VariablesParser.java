package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Event;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Type;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Value;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.ValuedVariable;
import org.camunda.bpm.model.bpmn.instance.Message;

import java.util.LinkedList;
import java.util.List;

public class VariablesParser {
    public static List<ValuedVariable> variables(Message message) {
        String variablesString = message.getName().split("\\(")[0];
        variablesString = variablesString.substring(0, variablesString.indexOf(")") - 1);

        List<ValuedVariable> variables = new LinkedList<>();
        for (String v : variablesString.split(", ")) {
            Value value = null;
            String[] varAndValue = v.split("=");
            if (varAndValue.length == 2)
                value = new Value(varAndValue[1]);
            String[] varParts = varAndValue[0].split(" ");
            ValuedVariable variable = new ValuedVariable(varParts[1], new Type(varParts[0]), value);

            variables.add(variable);
        }

        return variables;
    }

    public static List<Event> events(Message message) {
        List<Event> events = new LinkedList<>();
        variables(message).forEach(el -> events.add(new Event(FunctionParser.nameFunction(message), List.of(el))));

        return events;
    }
}
