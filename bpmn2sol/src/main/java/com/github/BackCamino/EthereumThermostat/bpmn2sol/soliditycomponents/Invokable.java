package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public interface Invokable {
	String invokation(Value... values);

	default String invokation(String source, Value... values) {
		// TODO consider using Variable instead of String for source
		return source + "." + invokation(values);
	}
}
