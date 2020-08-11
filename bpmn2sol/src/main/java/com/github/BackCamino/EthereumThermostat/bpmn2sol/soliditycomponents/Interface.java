package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public class Interface implements Extendable {
    private String name;

    public Interface(String name) {
        this.name = name;
    }
    // TODO

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String print() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public String invocation(Value... values) {
        // TODO Auto-generated method stub
        return null;
    }
}
