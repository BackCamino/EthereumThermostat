package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class Contract implements Extendable {
	private String name;
	private Constructor constructor;
	private Map<Extendable, List<Value>> extendeds;
	private Collection<Variable> attributes;
	private Collection<Function> functions;
	private Collection<Modifier> modifiers;
	private Collection<Event> events;
	private boolean isAbstract;

	public Contract(String name, Constructor constructor, Collection<Variable> attributes,
			Collection<Function> functions, Collection<Modifier> modifiers, Collection<Event> events) {
		this.name = name;
		this.constructor = constructor;
		this.attributes = new HashSet<>(attributes);
		this.functions = new HashSet<>(functions);
		this.modifiers = new HashSet<>(modifiers);
		this.events = new HashSet<>(events);
		this.extendeds = new HashMap<>();
	}

	public Contract(String name) {
		this(name, null, Set.of(), Set.of(), Set.of(), Set.of());
	}

	public void addAttribute(Variable attribute) {
		attributes.add(attribute);
	}

	public void addFunction(Function function) {
		functions.add(function);
	}

	public void addModifier(Modifier modifier) {
		modifiers.add(modifier);
	}

	public void addEvent(Event event) {
		events.add(event);
	}

	public void addExtended(Extendable toExtend, Value... variables) {
		extendeds.put(toExtend, List.of(variables));
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public boolean isAbstract() {
		return isAbstract;
	}

	public void setAbstract(boolean isAbstract) {
		this.isAbstract = isAbstract;
	}

	public Map<Extendable, List<Value>> getExtendeds() {
		return extendeds;
	}

	public Collection<Function> getFunctions() {
		return functions;
	}

	public Collection<Modifier> getModifiers() {
		return modifiers;
	}

	public Collection<Event> getEvents() {
		return events;
	}

	public String print() {
		StringBuilder toPrint = new StringBuilder();
		toPrint.append("contract " + this.name);
		if (!this.extendeds.isEmpty()) {
			toPrint.append(" is ");
			this.extendeds.entrySet().forEach(
					entry -> toPrint.append(entry.getKey().invokation(entry.getValue().toArray(new Value[0])) + ", "));
			toPrint.delete(toPrint.length() - 3, toPrint.length() - 1);
		}
		toPrint.append("{\n");
		this.attributes.forEach(el -> toPrint.append(el.printWithIndentation(1) + "\n"));
		toPrint.append("\n");
		this.events.forEach(el -> toPrint.append(el.printWithIndentation(1) + "\n"));
		toPrint.append("\n");
		this.modifiers.forEach(el -> toPrint.append(el.printWithIndentation(1) + "\n"));
		toPrint.append("\n");
		this.functions.forEach(el -> toPrint.append(el.printWithIndentation(1) + "\n"));
		toPrint.append("\n}");

		return toPrint.toString();
	}

	@Override
	public String invokation(Value... values) {
		return this.constructor.invokation(values);
	}
}
