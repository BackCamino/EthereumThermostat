package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.EmmanueleBollino.solcraft.soliditycomponents.*;

public class HashEnableRequire extends Require {
    private String id;

    public HashEnableRequire(String id) {
        super(new Condition("isEnabled(" + id + ")"), "Not enabled");
    }

    public String getId() {
        return id;
    }
}
