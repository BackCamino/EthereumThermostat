package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public enum Visibility implements SolidityComponent {
	PUBLIC, PRIVATE, EXTERNAL;

	public String print() {
		return this.name().toLowerCase();
	}
}
