package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;

public class SolidityFile implements SolidityComponent {
    private SPDXLicense license;
    private List<Pragma> pragmaDirectives;
    private Collection<Import> imports;
    private List<SolidityComponent> components;

    public SolidityFile(List<Pragma> pragmaDirectives, Collection<Import> imports, List<? extends SolidityComponent> components, SPDXLicense license) {
        this.pragmaDirectives = new LinkedList<>(pragmaDirectives);
        this.imports = new LinkedHashSet<>(imports);
        this.components = new LinkedList<>(components);
        this.license = license;
    }

    public SolidityFile() {
        this(List.of(new PragmaVersion()), List.of(), List.of(), new SPDXLicense());
    }

    public SolidityFile(List<Pragma> pragmaDirectives, Collection<Import> imports, List<? extends SolidityComponent> components) {
        this(pragmaDirectives, imports, components, new SPDXLicense());
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

        if (this.license != null) toPrint.append(this.license.print() + "\n");
        pragmaDirectives.forEach(el -> toPrint.append(el.print() + "\n"));
        toPrint.append("\n");
        imports.forEach(el -> toPrint.append(el.print()).append("\n"));
        toPrint.append("\n");
        components.forEach(el -> toPrint.append(el.print()).append("\n\n"));

        return toPrint.toString().trim();
    }
}
