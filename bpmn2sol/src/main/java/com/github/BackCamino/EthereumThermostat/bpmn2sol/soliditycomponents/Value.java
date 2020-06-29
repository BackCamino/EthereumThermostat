package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public class Value implements SolidityComponent {
	private Type type;
	private String value;

	public Value(Type type, String value) {
		this.type = type;
		this.value = value;
	}

	public Value(String value) {
		this(null, value);
	}

	public String print() {
		return value;
	}
}
