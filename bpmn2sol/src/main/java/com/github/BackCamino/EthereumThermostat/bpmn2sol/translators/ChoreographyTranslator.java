package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Contract;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Event;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Function;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.SolidityFile;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.ContractsSet;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.FunctionParser;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.VariablesParser;
import com.sun.tools.javac.Main;
import org.camunda.bpm.model.bpmn.BpmnModelInstance;
import org.camunda.bpm.model.bpmn.instance.Message;
import org.camunda.bpm.model.bpmn.instance.MessageFlow;
import org.camunda.bpm.model.bpmn.instance.Participant;

import java.util.Collection;
import java.util.logging.Logger;

import static java.util.function.Predicate.not;

public class ChoreographyTranslator extends Bpmn2SolidityTranslator {
    private static Logger LOGGER = Logger.getLogger(Main.class.getSimpleName());

    private ContractsSet contracts;
    //TODO

    public ChoreographyTranslator(BpmnModelInstance model) {
        super(model);
    }

    @Override
    protected boolean canTranslate(BpmnModelInstance model) {
        //TODO check if model is correct
        /*
        try {
            Bpmn.validateModel(this.getModel());
        } catch (ModelValidationException e) {
            return false;
        }
        */
        return true;
    }

    @Override
    public SolidityFile translate() {
        initializeContracts();

        return new SolidityFile();
    }

    private void initializeContracts() {
        this.contracts = new ContractsSet();
        this.getModel().getModelElementsByType(Participant.class)
                .parallelStream()
                .filter(not(this::isExtern))
                .forEach(contracts::add);
    }

    private void parseMessages() {
        Collection<MessageFlow> messageFlows = this.getModel().getModelElementsByType(MessageFlow.class);
        for (MessageFlow messageFlow : messageFlows) {
            parseSourceMessage(sourceContract(messageFlow), messageFlow.getMessage());
            parseTargetMessage(targetContract(messageFlow), messageFlow.getMessage());
        }
    }

    private Contract targetContract(MessageFlow messageFlow) {
        Participant participant = this.getModel().getModelElementById(messageFlow.getTarget().getId());
        return this.contracts.getContract(participant);
    }

    private Contract sourceContract(MessageFlow messageFlow) {
        Participant participant = this.getModel().getModelElementById(messageFlow.getSource().getId());
        return this.contracts.getContract(participant);
    }

    private void parseSourceMessage(Contract contract, Message message) {

    }

    private void parseTargetMessage(Contract contract, Message message) {
        Function function = FunctionParser.setterFunction(message);
        Collection<Event> events = VariablesParser.events(message);
        contract.addFunction(function);
    }
}
