package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public class PragmaVersion extends Pragma {
    public static final String DEFAULT_VERSION = "^0.6.9";

    public PragmaVersion(String version) {
        super(Directives.SOLIDITY, version);
    }

    public PragmaVersion() {
        super(Directives.SOLIDITY, DEFAULT_VERSION);
    }
}
