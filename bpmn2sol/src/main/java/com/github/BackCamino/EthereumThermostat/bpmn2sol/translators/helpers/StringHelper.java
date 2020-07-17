package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers;

import java.util.stream.Stream;

public class StringHelper {
    public static String joinCamelCase(String... strings) {
        StringBuilder result = new StringBuilder();
        Stream.of(strings)
                .map(StringHelper::capitalize)
                .forEach(result::append);

        return result.toString();
    }

    public static String capitalize(String string) {
        return string.substring(0, 1).toUpperCase() + string.substring(1).toLowerCase();
    }

    public static String decapitalize(String string) {
        return string.substring(0, 1).toLowerCase() + string.substring(1);
    }
}
