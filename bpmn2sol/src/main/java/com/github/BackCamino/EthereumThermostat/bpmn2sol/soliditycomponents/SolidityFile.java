package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

public class SolidityFile implements SolidityComponent {
	private Pragma pragma;
	private Collection<Import> imports;
	List<SolidityComponent> components;

	public SolidityFile() {
		this(new Pragma("^0.6.10"), List.of(), List.of());
	}

	public SolidityFile(Pragma pragma, Collection<Import> imports, List<? extends SolidityComponent> components) {
		this.pragma = pragma;
		this.imports = new LinkedList<>(imports);
		this.components = new LinkedList<>(components);
	}

	public void addComponent(SolidityComponent component) {
		components.add(component);
	}

	public List<SolidityComponent> getComponents() {
		return this.components;
	}

	@Override
	public String print() {
		StringBuilder toPrint = new StringBuilder();

		toPrint.append(pragma.print()).append("\n\n");
		imports.forEach(el -> toPrint.append(el.print()).append("\n"));
		toPrint.append("\n");
		components.forEach(el -> toPrint.append(el.print()).append("\n\n"));

		return toPrint.toString();
	}
}
