package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.nio.file.Path;

public class Import implements SolidityComponent {
    private String path;

    public Import(String path) {
        this.path = path;
    }

    public Import(Path path) {
        this(path.toString());
    }

    @Override
    public String print() {
        return "import \"" + path + "\";";
    }
}
