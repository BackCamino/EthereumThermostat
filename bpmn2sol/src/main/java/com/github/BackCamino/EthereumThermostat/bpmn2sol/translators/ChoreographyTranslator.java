package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.ContractsSet;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.StringHelper;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.VariablesParser;
import com.sun.tools.javac.Main;
import org.camunda.bpm.model.bpmn.BpmnModelInstance;
import org.camunda.bpm.model.bpmn.instance.Message;
import org.camunda.bpm.model.bpmn.instance.MessageFlow;
import org.camunda.bpm.model.bpmn.instance.Participant;
import org.camunda.bpm.model.bpmn.instance.Task;

import java.util.Collection;
import java.util.logging.Logger;
import java.util.stream.Collectors;

import static java.util.function.Predicate.not;

public class ChoreographyTranslator extends Bpmn2SolidityTranslator {
    private static final Logger LOGGER = Logger.getLogger(Main.class.getSimpleName());

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
        initializeConfigurations();
        parseMessages();

        return this.generateSolidityFile();
    }

    /**
     * Generates the solidity file containing the translated contracts
     *
     * @return
     */
    private SolidityFile generateSolidityFile() {
        SolidityFile solidityFile = new SolidityFile();
        this.contracts.forEach(solidityFile::addComponent);

        return solidityFile;
    }

    /**
     * Creates a contract for every non-external participant in the model
     */
    private void initializeContracts() {
        this.contracts = new ContractsSet();
        this.getModel().getModelElementsByType(Participant.class)
                .stream()
                .filter(not(this::isExtern))
                .forEach(contracts::add);
    }

    /**
     * Initializes the model with the given configuration tasks.
     * Looks for all the configurations tasks and for each configuration task, calls the corresponding parser.
     */
    private void initializeConfigurations() {
        getConfigurationTasks().forEach(task -> {
            switch (task.getName().split(" ")[1]) {
                case "ASSOCIATIONS":
                    configureAssociations(task);
                    break;
            }
        });
    }

    /**
     * Parses a "CONFIGURE ASSOCIATIONS" task
     *
     * @param task
     */
    private void configureAssociations(Task task) {
        //TODO
    }

    /**
     * Retrieves all the configurations tasks. A configuration task is a bpmn task whose name starts with "CONFIGURE"
     *
     * @return
     */
    private Collection<Task> getConfigurationTasks() {
        return this.getModel().getModelElementsByType(Task.class)
                .stream()
                .filter(el -> el.getName().startsWith("CONFIGURE"))
                .collect(Collectors.toSet());
    }

    /**
     * Looks through all the message flows and takes action for every
     */
    private void parseMessages() {
        Collection<MessageFlow> messageFlows = this.getModel().getModelElementsByType(MessageFlow.class);
        for (MessageFlow messageFlow : messageFlows) {
            if (!isExtern(sourceParticipant(messageFlow)))
                parseSourceMessage(sourceContract(messageFlow), messageFlow.getMessage(), targetParticipant(messageFlow));
            parseTargetMessage(targetContract(messageFlow), messageFlow.getMessage(), sourceParticipant(messageFlow));
        }
    }

    /**
     * Retrieves the source participant associated with the message flow
     *
     * @param messageFlow
     * @return
     */
    private Participant sourceParticipant(MessageFlow messageFlow) {
        return this.getModel().getModelElementById(messageFlow.getSource().getId());
    }

    /**
     * Retrieves the target participant associated with the message flow
     *
     * @param messageFlow
     * @return
     */
    private Participant targetParticipant(MessageFlow messageFlow) {
        return this.getModel().getModelElementById(messageFlow.getTarget().getId());
    }

    /**
     * Retrieves the contract associated to the target participant of a message flow
     *
     * @param messageFlow
     * @return
     */
    private Contract targetContract(MessageFlow messageFlow) {
        return this.contracts.getContract(targetParticipant(messageFlow));
    }

    /**
     * Retrieves the contract associated to the source participant of a message flow
     *
     * @param messageFlow
     * @return
     */
    private Contract sourceContract(MessageFlow messageFlow) {
        return this.contracts.getContract(sourceParticipant(messageFlow));
    }

    /**
     * Creates a function in a contract which sends info to the next task
     *
     * @param contract
     * @param message
     */
    private void parseSourceMessage(Contract contract, Message message, Participant target) {
        //TODO
    }

    /**
     * Creates a setter function in a contract related to an incoming message
     *
     * @param contract
     * @param message
     */
    private void parseTargetMessage(Contract contract, Message message, Participant source) {
        //add attributes
        Collection<? extends Variable> parameters = VariablesParser.variables(message);
        if (!isExtern(source)) {
            Struct attributesStruct = getIncomingAttributesStruct(contract, source);
            parameters.forEach(attributesStruct::addField);
        } else {
            parameters.forEach(contract::addAttribute);
        }

        //TODO parse extern attributes

        //add setter functions
        /*
        Function function = FunctionParser.setterFunction(message);
        Collection<Event> events = VariablesParser.events(message);
        contract.addFunction(function);*/
    }

    /**
     * Retrieves the struct of the incoming messages from a source contract and creates it if doesn't exist yet
     *
     * @param contract
     * @param source
     * @return
     */
    private Struct getIncomingAttributesStruct(Contract contract, Participant source) {
        String structTypeName = StringHelper.joinCamelCase(source.getName(), "Values");
        String mappingInstanceName = StringHelper.decapitalize(structTypeName);

        Struct structDeclaration = (Struct) contract.getDeclarations().stream()
                .filter(el -> el.getName().equals(structTypeName))
                .findAny()
                .orElse(new Struct(structTypeName));

        contract.addDeclaration(structDeclaration);
        Mapping sourceValuesMapping = new Mapping(new Type(source.getName()), structDeclaration);
        contract.addAttribute(new Variable(mappingInstanceName, sourceValuesMapping));

        return structDeclaration;
    }
}
