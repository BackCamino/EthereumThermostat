package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public class Type implements SolidityComponent {
	private String type;

	public Type(BaseTypes type) {
		this.type = type.print();
	}

	public Type(Extendable type) {
		this.type = type.print();
	}

	public Type(String type) {
		this.type = type;
	}

	public enum BaseTypes implements SolidityComponent {
		INT, UINT, ADDRESS, STRING, BOOL;

		public String print() {
			return this.name().toLowerCase();
		}
	}

	public String print() {
		return type;
	}
}
