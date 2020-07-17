package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public interface Declarable extends SolidityComponent {
    String DEFAULT_INDENTATION = "    ";

    String declaration();

    default String declarationWithIndentation(int indentationLevel) {
        StringBuilder toPrint = new StringBuilder(this.declaration());
        StringBuilder indentation = new StringBuilder();

        for (int i = 0; i < indentationLevel; i++)
            indentation.append(DEFAULT_INDENTATION);

        toPrint.insert(0, indentation.toString());
        return toPrint.toString().replace("\n", "\n" + indentation.toString());
    }

    String getName();
}
