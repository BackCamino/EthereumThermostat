package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Event;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Variable;

import java.util.List;
import java.util.stream.Collectors;

public class EventParser {
    public static List<Event> parseEvents(List<? extends Variable> parameters) {
        return parameters.stream()
                .map(el -> new Event(el.getName() + "Changed", List.of(el)))
                .collect(Collectors.toList());
    }
}
