package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Type;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Value;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.ValuedVariable;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Variable;
import org.camunda.bpm.model.bpmn.instance.Message;

import java.util.Collection;
import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;

public class VariablesParser {
    public static List<Value> values(Message message) {
        return variables(message).stream()
                .map(ValuedVariable::getValue)
                .collect(Collectors.toList());
    }

    public static List<ValuedVariable> variables(Message message) {
        String variablesString = message.getName().split("\\(")[1];
        variablesString = variablesString.substring(0, variablesString.indexOf(")"));

        List<ValuedVariable> variables = new LinkedList<>();
        for (String v : variablesString.split(", ")) {
            Value value = null;
            String[] varAndValue = v.split("=");
            if (varAndValue.length == 2)
                value = new Value(varAndValue[1].trim());
            String[] varParts = varAndValue[0].split(" ");
            ValuedVariable variable = new ValuedVariable(varParts[1], new Type(varParts[0]), value);

            variables.add(variable);
        }

        return variables;
    }

    public static List<Variable> parseExtVariables(Collection<ValuedVariable> variables) {
        //parses by external value
        //if the value is external, returns all variables (non valued) with the value name and the given variable type
        return variables.stream()
                .filter(el -> isExtern(el.getValue()))
                .map(el -> new Variable(parseExtName(el.getValue().print()), el.getType()))
                .collect(Collectors.toList());
    }

    public static List<ValuedVariable> parseExtValuedVariables(Collection<ValuedVariable> variables) {
        //parses by external value
        //if the value is external, returns all variables (non valued) with the value name and the given variable type
        return variables.stream()
                .filter(el -> isExtern(el.getValue()))
                .map(el -> new ValuedVariable(parseExtName(el.getValue().print()), el.getType(), null))
                .collect(Collectors.toList());
    }

    public static boolean isExtern(Value value) {
        return value.print().startsWith("EXT_");
    }

    public static boolean isExtern(Variable variable) {
        return variable.getName().startsWith("EXT_");
    }

    public static String parseExtName(String string) {
        return string.replaceFirst("EXT_", "");
    }

    public static List<ValuedVariable> parseTrueValuedVariables(List<ValuedVariable> variables) {
        return variables.stream().filter(el -> el.getValue() != null).collect(Collectors.toList());
    }

    public static List<ValuedVariable> parseNotValuedVariables(List<ValuedVariable> variables) {
        return variables.stream().filter(el -> el.getValue() == null).collect(Collectors.toList());
    }

    public static Value[] callingValues(List<ValuedVariable> variables) {
        List<Value> values = new LinkedList<>();

        for (ValuedVariable variable : variables) {
            if (variable.getValue() != null)
                values.add(new Value(parseExtName(variable.getValue().getValue())));
            else {
                String valueName = parseExtName(variable.getName());
                if (!valueName.startsWith("_")) valueName = "_" + valueName;
                values.add(new Value(valueName));
            }
        }

        return values.toArray(new Value[0]);
    }
}
