package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

public class Condition implements SolidityComponent {
    private String condition;

    public Condition(String condition) {
        this.condition = condition.trim();
        /*
        if (condition.split(" ").length == 3) {
            String[] parts = condition.split(" ");
            if (parts[1].equals("==")) {
                if (parts[2].equals("true"))
                    this.condition = parts[0];
                else if (parts[2].equals("false"))
                    this.condition = "!" + parts[0];
            } else if (parts[1].equals("!=")) {
                if (parts[2].equals("true"))
                    this.condition = "!" + parts[0];
                else if (parts[2].equals("false"))
                    this.condition = parts[0];
            }
        }
        //TODO uncomment
         */
    }

    public Condition(Condition firstCondition, String operator, Condition secondCondition) {
        this(firstCondition.print() + " " + operator + " " + secondCondition.print());
    }

    @Override
    public String print() {
        return this.condition;
    }
}
