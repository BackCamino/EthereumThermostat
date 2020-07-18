package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Function;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Statement;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.ValuedVariable;
import org.camunda.bpm.model.bpmn.instance.Message;

import java.util.List;

import static com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.VariablesParser.variables;

public class FunctionParser {
    public static String nameFunction(Message message) {
        return message.getName().split("\\(")[0];
    }

    public static Function baseFunction(Message message) {
        return new Function(nameFunction(message));
    }

    public static Function parametrizedFunction(Message message) {
        return parametrizedFunction(nameFunction(message), variables(message));
    }

    public static Function parametrizedFunction(String name, List<ValuedVariable> parameters) {
        Function function = new Function(name);
        //add attributes
        parameters.stream()
                .map(el -> new ValuedVariable(privateName(el.getName()), el.getType(), el.getValue()))
                .forEach(function::addParameter);

        return function;
    }


    public static Function setterFunction(Message message) {
        return setterFunction(nameFunction(message), variables(message));
    }

    public static Function setterFunction(String name, List<ValuedVariable> parameters) {
        //TODO consider values already provided
        Function function = parametrizedFunction(name, parameters);
        //add assignments
        parameters.stream()
                .map(el -> new Statement(publicName(el.getName()) + " = " + privateName(el.getName()) + ";"))
                .forEach(function::addStatement);

        return function;
    }

    public static String privateName(String name) {
        return name.startsWith("_") ? name : "_" + name;
    }

    public static String publicName(String name) {
        return name.startsWith("_") ? name.substring(1) : name;
    }

    public static Function sendFunction(Message message) {
        //TODO
        return null;
    }
}
