package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public interface SolidityComponent {
    String DEFAULT_INDENTATION = "    ";

    String print();

    default String printWithIndentation(int indentationLevel) {
        StringBuilder toPrint = new StringBuilder(this.print());
        StringBuilder indentation = new StringBuilder();

        for (int i = 0; i < indentationLevel; i++)
            indentation.append(DEFAULT_INDENTATION);

        toPrint.insert(0, indentation.toString());
        return toPrint.toString().replace("\n", "\n" + indentation.toString());
    }
}
