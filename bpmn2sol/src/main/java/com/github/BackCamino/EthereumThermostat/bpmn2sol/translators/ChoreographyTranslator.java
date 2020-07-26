package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents.AssociationStruct;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.*;
import com.sun.tools.javac.Main;
import org.camunda.bpm.model.bpmn.BpmnModelInstance;
import org.camunda.bpm.model.bpmn.instance.Message;
import org.camunda.bpm.model.bpmn.instance.MessageFlow;
import org.camunda.bpm.model.bpmn.instance.Participant;
import org.camunda.bpm.model.bpmn.instance.Task;
import org.camunda.bpm.model.xml.instance.ModelElementInstance;

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.StringHelper.capitalize;
import static com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.StringHelper.decapitalize;
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
        initializeCommunicatingContractsAttributes();
        addIsReadyFunction();
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
     * For every contract, adds the attributes representing the participants it deals with
     */
    private void initializeCommunicatingContractsAttributes() {
        this.getModel().getModelElementsByType(Participant.class)
                .stream()
                .filter(not(this::isExtern))
                .forEach(this::initializeCommunicatingContractsAttributes);
    }

    /**
     * Adds isReady function to every contract
     */
    private void addIsReadyFunction() {
        this.contracts.forEach(this::addIsReadyFunction);
    }

    /**
     * Adds isReady function to a specific contract
     *
     * @param contract
     */
    private void addIsReadyFunction(Contract contract) {
        Function function = new Function("isReady");
        function.addReturned(new Variable("_isReady", new Type(Type.BaseTypes.BOOL)));

        //check single instance contracts
        singleInstanceContractsDealingWith(contract).stream()
                .map(el -> new IfThenElse(isReadyCondition(el), List.of(new Statement("return false;"))))
                .forEach(function::addStatement);

        //check multiple instance contracts
        multiInstanceParticipantsDealingWith(getParticipant(contract.getName())).stream()
                .filter(this::isContract)
                .map(el -> new For(
                        new ValuedVariable("i", new Type(Type.BaseTypes.UINT), new Value(new Type(Type.BaseTypes.UINT), "0"))
                        , new Condition("i < " + el.getParticipantMultiplicity().getMaximum())
                        , new Statement("i++")
                        , List.of(new IfThenElse(isReadyCondition(decapitalize(el.getName()) + "Values[i]." + decapitalize(el.getName())), List.of(new Statement("return false;"))))
                ))
                .forEach(function::addStatement);

        function.addStatement(new Statement("return true;"));
        contract.addFunction(function);
    }

    private Condition isReadyCondition(Contract contract) {
        return this.isReadyCondition(contract.getName());
    }

    private Condition isReadyCondition(String contractVariableName) {
        String variableName = decapitalize(contractVariableName);
        //address(<variableName) == address(0) || !<variableName>.isReady()
        return new Condition("address(" + variableName + ") == address(0) || !" + variableName + ".isReady()");
    }

    private boolean isContract(Participant participant) {
        return !isExtern(participant);
    }

    /**
     * Adds the attributes representing the participants the given contract deals with
     *
     * @param participant
     */
    private void initializeCommunicatingContractsAttributes(Participant participant) {
        Contract contract = this.contracts.getContract(participant);

        //add external participants attributes
        externalParticipantsDealingWith(participant).stream()
                .distinct()
                .map(el -> new Variable(decapitalize(VariablesParser.parseExtName(el.getName())), new Type(Type.BaseTypes.ADDRESS)))
                .forEach(contract::addAttribute);

        //add single instance contracts attributes
        singleInstanceContractsDealingWith(participant).stream()
                .distinct()
                .map(el -> new Variable(decapitalize(el.getName()), new Type(capitalize(el.getName()))))
                .forEach(contract::addAttribute);

        //TODO split in multiple functions
        //add struct <Participant>Values, array of that struct and mapping to the index
        for (Participant multiInstanceParticipant : multiInstanceParticipantsDealingWith(participant)) {
            String miParticipantName = multiInstanceParticipant.getName();
            //add struct <Participant>Values
            Struct participantValues = getIncomingAttributesStruct(contract, multiInstanceParticipant);
            //add participant in struct
            participantValues.addField(new Variable(decapitalize(miParticipantName), new Type(capitalize(miParticipantName)), Visibility.NONE), 0);
            //add association struct array index
            participantValues.addField(new Variable("associationIndex", new Type(Type.BaseTypes.UINT), Visibility.NONE), 1);
            contract.addDeclaration(participantValues);

            //add array of struct <Participant>Values
            int maxMultiplicity = multiInstanceParticipant.getParticipantMultiplicity().getMaximum();
            Variable arrayOfStruct = new Variable(decapitalize(participantValues.getName()), new Type(participantValues.getName() + "[" + maxMultiplicity + "]")); //TODO add array type
            contract.addAttribute(arrayOfStruct);

            //add mapping from <Participant> to uint which is the index in arrayOfStruct
            Mapping mappingDeclaration = new Mapping(new Type(multiInstanceParticipant.getName()), new Type(Type.BaseTypes.UINT));
            Variable mappingInstantiation = new Variable(decapitalize(multiInstanceParticipant.getName() + "Index"), mappingDeclaration);
            contract.addAttribute(mappingInstantiation);
        }
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
        //prepare configuration string
        String taskName = task.getName();
        taskName = taskName.replaceFirst("CONFIGURE ASSOCIATIONS", "");
        taskName = taskName.replaceAll(" ", "");
        String[] parts = taskName.split("\\)\\{");
        parts[0] = parts[0].replace("(", "");
        parts[1] = parts[1].replace("}", "");
        String[] participantsNames = parts[0].split(",");
        String[] associationCouples = parts[1].split(";");

        List<Participant> participants = Stream.of(participantsNames)
                .map(this::getParticipant)
                .collect(Collectors.toList());

        //create association struct
        AssociationStruct associationStruct = new AssociationStruct(participants);
        associationStruct.addField(new Variable("activations", new Mapping(new Type(Type.BaseTypes.UINT), new Type(Type.BaseTypes.BOOL)), Visibility.NONE));

        //create association struct array
        Variable associationsArray = new Variable("associations", new Array(associationStruct, associationCouples.length));

        //create associations from given configuration string
        List<Association> associations = new LinkedList<>();
        for (String couple : associationCouples) {
            couple = couple.replace("[", "").replace("]", "");
            String[] indexes = couple.split(",");
            Association association = new Association();
            for (int i = 0; i < indexes.length; i++) {
                IndexedParticipant indexedParticipant = new IndexedParticipant(participants.get(i), Integer.parseInt(indexes[i]));
                association.addParticipant(indexedParticipant);
            }
            associations.add(association);
        }

        //create associations assignment statements
        List<Statement> assignmentStatements = new LinkedList<>();
        for (int i = 0; i < associations.size(); i++) {
            //add assignment in association
            StringBuilder statementString = new StringBuilder("associations[" + i + "] = Association(");
            associations.get(i)
                    .getParticipants().stream()
                    .map(IndexedParticipant::getIndex)
                    .map(el -> el + ", ")
                    .forEach(statementString::append);
            statementString.setLength(statementString.length() - 2);
            statementString.append(");");
            assignmentStatements.add(new Statement(statementString.toString()));

            //add assignment in <participant>Values (<participant>Values[<participantIndex>.associationIndex = <associationIndex>;
            int finalI = i;
            associations.get(i)
                    .getParticipants().stream()
                    .filter(el -> isMultiInstance(el.getParticipant()))
                    .map(el -> new Statement(decapitalize(el.getParticipant().getName()) + "Values[" + el.getIndex() + "].associationIndex = " + finalI + ";"))
                    .forEach(assignmentStatements::add);
            assignmentStatements.add(new Statement(""));
        }
        assignmentStatements.remove(assignmentStatements.size() - 1);

        //add values to contracts
        for (Contract contract : this.contracts) {
            boolean shouldBeConfigured = false;
            for (Participant p : multiInstanceParticipantsDealingWith(getParticipant(contract.getName()))) {
                if (participants.contains(p)) {
                    shouldBeConfigured = true;
                    break;
                }
            }
            if (!shouldBeConfigured)
                continue;

            //add statements to constructor
            Constructor constructor = contract.getConstructor();
            if (constructor == null)
                constructor = new Constructor(contract.getName());
            assignmentStatements.forEach(constructor::addStatement);
            contract.setConstructor(constructor);

            //add association struct
            contract.addDeclaration(associationStruct);

            //add association struct array
            contract.addAttribute(associationsArray);

            //TODO add association index in <Participant>Values
            //TODO
        }
    }

    private Participant getParticipant(String name) {
        return this.getModel().getModelElementsByType(Participant.class).stream()
                .filter(el -> el.getName().equals(name))
                .findAny()
                .orElse(null);
    }

    private class IndexedParticipant {
        private Participant participant;
        private int index;

        public IndexedParticipant(Participant participant, int index) {
            this.participant = participant;
            this.index = index;
        }

        public Participant getParticipant() {
            return participant;
        }

        public int getIndex() {
            return index;
        }
    }

    private class Association {
        private List<IndexedParticipant> participants;

        public Association() {
            this(List.of());
        }

        public Association(List<IndexedParticipant> participants) {
            this.participants = new LinkedList<>(participants);
        }

        public List<IndexedParticipant> getParticipants() {
            return participants;
        }

        public void addParticipant(IndexedParticipant participant) {
            this.participants.add(participant);
        }
    }

    /**
     * Retrieves all the configurations tasks. A configuration task is a bpmn task whose name starts with "CONFIGURE"
     *
     * @return
     */
    private Collection<Task> getConfigurationTasks() {
        return this.getModel().getModelElementsByType(Task.class)
                .stream()
                .filter(this::isConfigurationTask)
                .collect(Collectors.toSet());
    }

    private boolean isConfigurationTask(ModelElementInstance modelElementInstance) {
        if (!(modelElementInstance instanceof Task))
            return false;
        Task task = (Task) modelElementInstance;
        if (task.getName().startsWith("CONFIGURE"))
            return true;
        return false;
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
        //parse external attributes
        Collection<Variable> externals = VariablesParser.parseExtVariables(VariablesParser.variables(message));
        externals.stream().forEach(contract::addAttribute);     //add attribute in contract for each external
        //setter function for externals
        if (externals.size() > 0) {
            List<ValuedVariable> toBeSet = externals.stream()
                    .map(el -> new ValuedVariable(el.getName(), el.getType(), null))
                    .collect(Collectors.toList());
            Function setterFunction = FunctionParser.setterFunction("set_" + FunctionParser.nameFunction(message), toBeSet);
            Collection<Event> setterEvents = EventParser.parseEvents(toBeSet);
            setterEvents.forEach(el -> setterFunction.addStatement(new Statement(el.invocation(new Value("_" + el.getName().replaceFirst("Changed", "")))))); //adds event emit for every parameter
            contract.addFunction(setterFunction);
            setterEvents.forEach(contract::addEvent);
        }
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
        String sourceSetter = null;
        if (!isExtern(source) && isMultiInstance(source)) {
            //creates struct <Participant>Values
            Struct attributesStruct = getIncomingAttributesStruct(contract, source);
            parameters.forEach(attributesStruct::addField);
            sourceSetter = decapitalize(attributesStruct.getName()) + "[" + source.getName() + "(msg.sender)]";
        } else {
            parameters.forEach(contract::addAttribute);
        }

        //add setter function
        Function function = FunctionParser.setterFunction(message, sourceSetter);
        contract.addFunction(function);

        //add events TODO
        Collection<Event> events = EventParser.parseEvents(message);
        if (isMultiInstance(source))
            events.forEach(el -> el.addParameter(new Variable("_" + decapitalize(source.getName()), new Type(capitalize(source.getName())))));
        events.forEach(contract::addEvent);

        events.forEach(el -> function.addStatement(new Statement(el.invocation(eventChangedAttributes(el, source)))));

        //TODO
    }

    private Value[] eventChangedAttributes(Event event, Participant source) {
        List<Value> values = new ArrayList<>();
        values.add(new Value("_" + event.getName().replaceFirst("Changed", "")));
        if (source != null && isMultiInstance(source))
            values.add(new Value(source.getName() + "(msg.sender)"));

        return values.toArray(new Value[0]);
    }

    /**
     * Determines whether a participant is multi-instance or not
     *
     * @param participant
     * @return
     */
    private boolean isMultiInstance(Participant participant) {
        if (participant.getParticipantMultiplicity() == null) return false;
        return participant.getParticipantMultiplicity().getMaximum() > 1;
    }

    /**
     * Retrieves the struct of the incoming messages from a source contract and creates it if doesn't exist yet but doesn't add it to the contract
     *
     * @param contract
     * @param source
     * @return
     */
    private Struct getIncomingAttributesStruct(Contract contract, Participant source) {
        return getIncomingAttributesStruct(contract, source.getName());
    }

    /**
     * Retrieves the struct of the incoming messages from a source contract and creates it if doesn't exist yet but doesn't add it to the contract
     *
     * @param contract
     * @param source
     * @return
     */
    private Struct getIncomingAttributesStruct(Contract contract, Contract source) {
        return getIncomingAttributesStruct(contract, source.getName());
    }

    /**
     * Retrieves the struct of the incoming messages from a source contract and creates it if doesn't exist yet but doesn't add it to the contract
     *
     * @param contract
     * @param source
     * @return
     */
    private Struct getIncomingAttributesStruct(Contract contract, String source) {
        String structTypeName = StringHelper.joinCamelCase(source, "Values");

        return (Struct) contract.getDeclarations().stream()
                .filter(el -> el.getName().equals(structTypeName))
                .findAny()
                .orElse(new Struct(structTypeName));
    }

    /**
     * Finds all the participants dealing with (sending to or receiving from) the given participant
     *
     * @param participant
     * @return
     */
    private Collection<Participant> participantsDealingWith(Participant participant) {
        return this.getModel().getModelElementsByType(MessageFlow.class).stream()
                .filter(el -> targetParticipant(el).equals(participant) || sourceParticipant(el).equals(participant))
                .map(el -> sourceParticipant(el).equals(participant) ? targetParticipant(el) : sourceParticipant(el))
                .collect(Collectors.toSet());
    }

    /**
     * Finds all the external participants dealing with the given participant
     *
     * @param participant
     * @return
     */
    private Collection<Participant> externalParticipantsDealingWith(Participant participant) {
        return participantsDealingWith(participant).stream()
                .filter(this::isExtern)
                .collect(Collectors.toSet());
    }

    /**
     * Finds all the multi-instance contracts dealing with the given participant
     *
     * @param participant
     * @return
     */
    private Collection<Contract> multiInstanceContractsDealingWith(Participant participant) {
        return participantsDealingWith(participant).stream()
                .filter(this::isMultiInstance)
                .filter(this.contracts::contains)
                .map(this.contracts::getContract)
                .collect(Collectors.toSet());
    }

    /**
     * Finds all the multi-instance participants dealing with the given participant
     *
     * @param participant
     * @return
     */
    private Collection<Participant> multiInstanceParticipantsDealingWith(Participant participant) {
        return participantsDealingWith(participant).stream()
                .filter(this::isMultiInstance)
                .collect(Collectors.toSet());
    }

    /**
     * Finds all the single-instance contracts dealing with the given participant
     *
     * @param participant
     * @return
     */
    private Collection<Contract> singleInstanceContractsDealingWith(Participant participant) {
        return participantsDealingWith(participant).stream()
                .filter(not(this::isExtern))
                .filter(not(this::isMultiInstance))
                .map(this.contracts::getContract)
                .collect(Collectors.toSet());
    }

    private Collection<Contract> singleInstanceContractsDealingWith(Contract contract) {
        return singleInstanceContractsDealingWith(getParticipant(contract.getName()));
    }
}
