package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers;

import com.github.EmmanueleBollino.solcraft.soliditycomponents.*;
import org.camunda.bpm.model.bpmn.instance.Message;

import java.util.List;
import java.util.stream.Collectors;

import static com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.StringHelper.decapitalize;
import static com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.VariablesParser.variables;

public class EventParser {
    public static List<Event> parseEvents(List<? extends Variable> parameters) {
        return parameters.stream()
                .map(el -> new Event(el.getName() + "Changed", List.of(el)))
                .collect(Collectors.toList());
    }

    public static List<Event> parseEvents(Message message) {
        return parseEvents(variables(message));
    }

    public static List<Event> parseEvents(List<? extends Variable> parameters, Contract source) {
        return parameters.stream()
                .map(el -> new Event(el.getName() + "Changed", List.of(el, new Variable(decapitalize(source.getName()), new Type(source.getName())))))
                .collect(Collectors.toList());
    }
}
