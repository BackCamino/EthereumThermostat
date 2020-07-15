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
        Function function = baseFunction(message);
        List<ValuedVariable> parameters = variables(message);

        parameters.forEach(function::addParameter);

        return function;
    }

    public static Function setterFunction(Message message) {
        Function function = parametrizedFunction(message);
        List<ValuedVariable> parameters = variables(message);

        parameters.forEach(el -> function.addStatement(new Statement(el.getName() + " = _" + el.getName())));

        return function;
    }

    public static Function sendFunction(Message message) {
        //TODO
        return null;
    }
}
