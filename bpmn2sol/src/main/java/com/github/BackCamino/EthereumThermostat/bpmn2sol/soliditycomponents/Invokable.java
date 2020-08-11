package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public interface Invokable {
    String invocation(Value... values);

    default String invocation(String source, Value... values) {
        // TODO consider using Variable instead of String for source
        return (source != null ? (source + ".") : ("")) + this.invocation(values);
    }
}
