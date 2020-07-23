package com.github.BackCamino.EthereumThermostat.bpmn2sol;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.Bpmn2SolidityTranslator;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.ChoreographyTranslator;
import com.sun.tools.javac.Main;
import org.camunda.bpm.model.bpmn.Bpmn;
import org.camunda.bpm.model.bpmn.BpmnModelInstance;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.logging.Logger;

public class Bpmn2sol {
    private static Logger LOGGER = Logger.getLogger(Main.class.getSimpleName());

    public static void main(String[] args) {
        LOGGER.info("Reading model file");
        BpmnModelInstance model = Bpmn.readModelFromFile(new File("./diagram.bpmn"));
        LOGGER.info("Creating translator");
        Bpmn2SolidityTranslator translator = new ChoreographyTranslator(model);
        LOGGER.info("Translating");
        String translated = translator.translate().print();
        LOGGER.info("Translating done");
        try {
            Files.writeString(Path.of("./translated.sol"), translated);
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.println(translated);
    }
}
