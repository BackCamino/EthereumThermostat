package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;
import org.camunda.bpm.model.bpmn.instance.Message;

import java.util.LinkedList;
import java.util.List;

public class VariablesParser {
    public static List<ValuedVariable> variables(Message message) {
        String variablesString = message.getName().split("\\(")[1];
        variablesString = variablesString.substring(0, variablesString.indexOf(")"));
        
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

    public static boolean isExtern(Value value){
        return value.print().startsWith("ext_");
    }

    public static boolean isExtern(Variable variable){
        return variable.getName().startsWith("ext_");
    }
}
