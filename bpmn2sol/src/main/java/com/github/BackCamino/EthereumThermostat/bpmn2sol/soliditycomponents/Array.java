package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.stream.Stream;

public class Array extends Type {
    private Integer[] dimensions;

    public Array(Type type, Integer... dimensions) {
        super(type.print());
        this.dimensions = dimensions;
    }

    @Override
    public String print() {
        StringBuilder typeName = new StringBuilder(super.print());
        Stream.of(dimensions)
                .map(el -> "[" + (el == null ? "" : el) + "]")
                .forEach(typeName::append);

        return typeName.toString();
    }
}
