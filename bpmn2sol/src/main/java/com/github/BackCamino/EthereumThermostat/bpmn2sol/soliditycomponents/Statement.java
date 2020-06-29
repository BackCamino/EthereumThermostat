package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public class Statement implements SolidityComponent {
	private String statement;

	public Statement(String statement) {
		this.statement = statement;
	}

	public String print() {
		return statement;
	}
}
