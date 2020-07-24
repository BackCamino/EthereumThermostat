package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.*;

public class Contract implements Extendable {
    private String name;
    private Constructor constructor;
    private Map<Extendable, List<Value>> extendeds;
    private Set<Variable> attributes;
    private Set<Function> functions;
    private Set<Modifier> modifiers;
    private Set<Event> events;
    private Set<Declarable> declarations;
    private boolean isAbstract;

    public Contract(String name, Constructor constructor, Collection<Variable> attributes,
                    Collection<Function> functions, Collection<Modifier> modifiers, Collection<Event> events, Collection<Declarable> declarations) {
        this.name = name;
        this.constructor = constructor;
        this.attributes = new HashSet<>(attributes);
        this.functions = new HashSet<>(functions);
        this.modifiers = new HashSet<>(modifiers);
        this.events = new HashSet<>(events);
        this.declarations = new HashSet<>(declarations);
        this.extendeds = new HashMap<>();
    }

    public Contract(String name) {
        this(name, null, Set.of(), Set.of(), Set.of(), Set.of(), Set.of());
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

    public void addDeclaration(Declarable declaration) {
        declarations.add(declaration);
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

    public Constructor getConstructor() {
        return constructor;
    }

    public void setConstructor(Constructor constructor) {
        this.constructor = constructor;
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

    public Collection<Declarable> getDeclarations() {
        return this.declarations;
    }

    public Collection<Variable> getAttributes() {
        return attributes;
    }

    public String print() {
        StringBuilder toPrint = new StringBuilder();
        toPrint.append("contract " + this.name);
        if (!this.extendeds.isEmpty()) {
            toPrint.append(" is ");
            this.extendeds.forEach((key, value) -> toPrint.append(key.invocation(value.toArray(new Value[0])) + ", "));
            toPrint.delete(toPrint.length() - 3, toPrint.length() - 1);
        }
        toPrint.append(" {\n");
        this.declarations.forEach(el -> toPrint.append(el.declarationWithIndentation(1) + "\n\n"));
        this.attributes.forEach(el -> toPrint.append(el.printWithIndentation(1) + "\n"));
        if (!this.attributes.isEmpty()) toPrint.append("\n");
        this.events.forEach(el -> toPrint.append(el.printWithIndentation(1) + "\n"));
        if (!this.events.isEmpty()) toPrint.append("\n");
        if (this.constructor != null) toPrint.append(this.constructor.printWithIndentation(1) + "\n\n");
        this.modifiers.forEach(el -> toPrint.append(el.printWithIndentation(1) + "\n\n"));
        if (!this.modifiers.isEmpty()) toPrint.append("\n");
        this.functions.forEach(el -> toPrint.append(el.printWithIndentation(1) + "\n\n"));

        return toPrint.toString().trim() + "\n}";
    }

    @Override
    public String invocation(Value... values) {
        return this.constructor == null ? this.name : this.constructor.invocation(values);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Contract)) return false;
        Contract contract = (Contract) o;
        return name.equals(contract.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name);
    }
}
