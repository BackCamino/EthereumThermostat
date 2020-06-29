package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Objects;

public class Pragma implements SolidityComponent {
	private String version;

	public Pragma(String version) {
		Objects.requireNonNull(version);
		this.version = version;
	}

	public String getVersion() {
		return version;
	}

	public void setVersion(String version) {
		this.version = version;
	}

	public String print() {
		return "pragma solidity " + version + ";";
	}
}
