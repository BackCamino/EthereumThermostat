package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Condition;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Require;

public class HashEnableRequire extends Require {
    private String id;

    public HashEnableRequire(String id) {
        super(new Condition("isEnabled(" + id + ")"), "Not enabled");
    }

    public String getId() {
        return id;
    }
}
