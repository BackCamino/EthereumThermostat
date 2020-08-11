package com.github.BackCamino.EthereumThermostat.bpmn2sol.solidityhelpers;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Enum;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;

import java.util.Collection;
import java.util.LinkedList;
import java.util.stream.Collectors;

public class SolidityFileSplitter {
    public static Collection<SolidityFile> splitSolidityFile(SolidityFile solidityFile) {
        Collection<SolidityFile> solidityFiles = new LinkedList<>();

        SolidityFile other = new SolidityFile("Complementary");

        for (SolidityComponent component : solidityFile.getComponents()) {
            SolidityFile fileToAdd;
            if (component instanceof Contract)
                fileToAdd = new SolidityFile(((Contract) component).getName());
            else if (component instanceof Interface)
                fileToAdd = new SolidityFile(((Interface) component).getName());
            else if (component instanceof Enum)
                fileToAdd = new SolidityFile(((Enum) component).getName());
            else
                fileToAdd = other;

            fileToAdd.addComponent(component);
            fileToAdd.setImports(solidityFile.getImports());
            fileToAdd.setPragmaDirectives(solidityFile.getPragmaDirectives());
            fileToAdd.setLicense(solidityFile.getLicense());
            solidityFiles.add(fileToAdd);
        }

        Collection<Import> imports = solidityFiles.stream()
                .map(SolidityFile::getFileName)
                .map(el -> "./" + el)
                .map(Import::new)
                .collect(Collectors.toSet());

        solidityFiles.forEach(file -> imports.stream().filter(im -> !im.getPath().equals("./" + file.getFileName())).forEach(file::addImport));

        return solidityFiles;
    }
}
