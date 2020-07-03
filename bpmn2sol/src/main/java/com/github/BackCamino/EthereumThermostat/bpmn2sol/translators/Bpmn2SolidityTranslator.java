package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.SolidityFile;
import org.camunda.bpm.model.bpmn.BpmnModelInstance;

import java.util.Objects;

public abstract class Bpmn2SolidityTranslator {
    private final BpmnModelInstance model;

    public Bpmn2SolidityTranslator(BpmnModelInstance model) {
        Objects.requireNonNull(model);
        if (!canTranslate(model))
            throw new IllegalArgumentException("This translator can't translate this model");
        this.model = model.clone();
    }

    public BpmnModelInstance getModel() {
        return this.model;
    }

    protected abstract boolean canTranslate(BpmnModelInstance model);

    public abstract SolidityFile translate();
}
