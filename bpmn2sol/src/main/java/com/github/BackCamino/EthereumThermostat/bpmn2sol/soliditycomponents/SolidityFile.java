package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;

public class SolidityFile implements SolidityComponent {
    private String fileName;
    private SPDXLicense license;
    private List<Pragma> pragmaDirectives;
    private Collection<Import> imports;
    private List<SolidityComponent> components;

    public SolidityFile(String fileName, List<Pragma> pragmaDirectives, Collection<Import> imports, List<? extends SolidityComponent> components, SPDXLicense license) {
        this.fileName = fileName;
        this.pragmaDirectives = new LinkedList<>(pragmaDirectives);
        this.imports = new LinkedHashSet<>(imports);
        this.components = new LinkedList<>(components);
        this.license = license;
    }

    public SolidityFile(String fileName) {
        this(fileName, List.of(new PragmaVersion()), List.of(), List.of(), new SPDXLicense());
    }

    public SolidityFile(String fileName, List<Pragma> pragmaDirectives, Collection<Import> imports, List<? extends SolidityComponent> components) {
        this(fileName, pragmaDirectives, imports, components, new SPDXLicense());
    }

    public void addComponent(SolidityComponent component) {
        components.add(component);
    }

    public List<SolidityComponent> getComponents() {
        return this.components;
    }

    public void addImport(Import _import) {
        this.imports.add(_import);
    }

    public void addPragmaDirective(Pragma pragma) {
        this.pragmaDirectives.add(pragma);
    }

    public String getFileName() {
        return fileName + ".sol";
    }

    public void setLicense(SPDXLicense license) {
        this.license = license;
    }

    public void setPragmaDirectives(List<Pragma> pragmaDirectives) {
        this.pragmaDirectives = pragmaDirectives;
    }

    public void setImports(Collection<Import> imports) {
        this.imports = imports;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public SPDXLicense getLicense() {
        return license;
    }

    public List<Pragma> getPragmaDirectives() {
        return pragmaDirectives;
    }

    public Collection<Import> getImports() {
        return imports;
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
