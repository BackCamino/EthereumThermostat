package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public class SPDXLicense extends Comment {
    private static String IDENTIFIER = "SPDX-License-Identifier:";

    public enum Licenses implements SolidityComponent {
        UNLICENSED,
        MIT;

        @Override
        public String print() {
            return this.name();
        }
    }

    public SPDXLicense(Licenses license) {
        super(IDENTIFIER + " " + license.print());
    }

    public SPDXLicense() {
        this(Licenses.UNLICENSED);
    }
}
