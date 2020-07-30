package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.bpmnelements.ChoreographyTask;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Condition;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Event;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents.AssociationStruct;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents.ForEnableAssociations;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents.OwnedContract;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.*;
import com.sun.tools.javac.Main;
import org.camunda.bpm.model.bpmn.BpmnModelInstance;
import org.camunda.bpm.model.bpmn.instance.*;
import org.camunda.bpm.model.xml.impl.instance.ModelElementInstanceImpl;
import org.camunda.bpm.model.xml.instance.ModelElementInstance;

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.StringHelper.*;
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
        configureActivations();
        addSetterParticipantFunctions();
        initializeConfigurations();
        parseChoreographyTasks();
        parseGateways();

        return this.generateSolidityFile();
    }

    private void configureActivations() {
        Variable idVariable = new Variable("id", new Type(Type.BaseTypes.INT));
        Variable associationVariable = new Variable("_association", new AssociationStruct(), Visibility.NONE, Variable.Location.STORAGE);
        Mapping activationMapping = new Mapping(new Type(Type.BaseTypes.INT), new Type(Type.BaseTypes.BOOL));
        Function siIsEnabled = new Function(
                "isEnabled",
                Visibility.INTERNAL,
                List.of(idVariable),
                List.of(new Statement("return activations[_id];")),
                false,
                List.of(new Variable("_isEnabled", new Type(Type.BaseTypes.BOOL))),
                Function.Markers.VIEW
        );
        Function miIsEnabled = new Function(
                "isEnabled",
                Visibility.INTERNAL,
                List.of(idVariable, associationVariable),
                List.of(new Statement("return _association.activations[_id];")),
                false,
                List.of(new Variable("_isEnabled", new Type(Type.BaseTypes.BOOL))),
                Function.Markers.VIEW
        );
        Function siEnable = new Function("enable");
        siEnable.setVisibility(Visibility.INTERNAL);
        siEnable.addParameter(idVariable);
        siEnable.addStatement(new Statement("activations[_id] = true;"));
        Function siDisable = new Function("disable");
        siDisable.setVisibility(Visibility.INTERNAL);
        siDisable.addParameter(idVariable);
        siDisable.addStatement(new Statement("activations[_id] = false;"));
        Function miEnable = new Function("enable");
        miEnable.setVisibility(Visibility.INTERNAL);
        miEnable.addParameter(idVariable);
        miEnable.addParameter(associationVariable);
        miEnable.addStatement(new Statement("_association.activations[_id] = true;"));
        Function miDisable = new Function("disable");
        miDisable.setVisibility(Visibility.INTERNAL);
        miDisable.addParameter(idVariable);
        miDisable.addParameter(associationVariable);
        miDisable.addStatement(new Statement("_association.activations[_id] = false;"));

        this.contracts.stream()
                .filter(el -> multiInstanceContractsDealingWith(getParticipant(el.getName())).size() == 0)
                .peek(el -> el.addAttribute(new Variable("activations", activationMapping, Visibility.NONE)))
                .peek(el -> el.addFunction(siDisable))
                .peek(el -> el.addFunction(siEnable))
                .forEach(el -> el.addFunction(siIsEnabled));

        this.contracts.stream()
                .filter(el -> multiInstanceContractsDealingWith(getParticipant(el.getName())).size() > 0)
                .peek(el -> el.addFunction(miDisable))
                .peek(el -> el.addFunction(miEnable))
                .forEach(el -> el.addFunction(miIsEnabled));
    }

    /**
     * Generates the solidity file containing the translated contracts
     *
     * @return
     */
    private SolidityFile generateSolidityFile() {
        SolidityFile solidityFile = new SolidityFile();
        OwnedContract ownedContract = new OwnedContract();
        solidityFile.addComponent(ownedContract);
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

        //all contracts must extend Owned
        OwnedContract ownedContract = new OwnedContract();
        this.contracts.forEach(el -> el.addExtended(ownedContract));
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
                        , new Condition("i < " + decapitalize(el.getName()) + "Values.length")
                        , new Statement("i++")
                        , List.of(new IfThenElse(isReadyCondition(decapitalize(el.getName()) + "Values[i]." + decapitalize(el.getName())), List.of(new Statement("return false;"))))
                ))
                .forEach(function::addStatement);

        function.addStatement(new Statement("return true;"));
        contract.addFunction(function);
    }

    /**
     * Adds setter functions for every participant
     */
    private void addSetterParticipantFunctions() {
        for (Contract contract : this.contracts)
            for (Participant participant : participantsDealingWith(getParticipant(contract.getName())))
                addSetterParticipantFunctions(contract, participant);
    }

    /**
     * Adds setter function in a contract for a specific participant
     *
     * @param contract
     * @param participant
     */
    private void addSetterParticipantFunctions(Contract contract, Participant participant) {
        Function function = isMultiInstance(participant) ? miSetterParticipantFunction(participant) : siSetterParticipantFunction(participant);
        function.addModifier(OwnedContract.onlyOwnerModifier());
        contract.addFunction(function);
    }

    private Function siSetterParticipantFunction(Participant participant) {
        String participantName = decapitalize(VariablesParser.parseExtName(participant.getName()));
        Function function = baseSetterParticipantFunction(participant);
        function.addStatement(new Statement(participantName + " = _" + participantName + ";"));

        return function;
    }

    private Function miSetterParticipantFunction(Participant participant) {
        String participantName = decapitalize(VariablesParser.parseExtName(participant.getName()));
        Function function = baseSetterParticipantFunction(participant);

        function.addParameter(new Variable("id", new Type(Type.BaseTypes.UINT)));

        Statement indexAssignment = new Statement(participantName + "Index[_" + participantName + "] = _id;");
        Statement participantValuesAssignment = new Statement(participantName + "Values[_id]." + participantName + " = _" + participantName + ";");
        function.addStatement(indexAssignment);
        function.addStatement(participantValuesAssignment);

        return function; //TODO
    }

    private Function baseSetterParticipantFunction(Participant participant) {
        String participantName = decapitalize(VariablesParser.parseExtName(participant.getName()));
        Function function = new Function(decapitalize(joinCamelCase("initialize", participantName, "address")));
        Type parameterType = isExtern(participant) ? new Type(Type.BaseTypes.ADDRESS) : new Type(capitalize(participant.getName()));
        function.addParameter(new Variable(participantName, parameterType));

        return function;
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

            //add function getValues
            Function getValues = new Function("getValues");
            Variable functionParameter = new Variable(decapitalize(miParticipantName), new Type(capitalize(miParticipantName)));
            getValues.addParameter(functionParameter);
            getValues.setMarker(Function.Markers.VIEW);
            getValues.setVisibility(Visibility.INTERNAL);
            getValues.addReturned(new Variable("storage _values", participantValues));
            getValues.addStatement(new Statement("return " + arrayOfStruct.getName() + "[" + mappingInstantiation.getName() + "[" + functionParameter.getName() + "]];"));
            contract.addFunction(getValues);
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
        associationStruct.addField(new Variable("activations", new Mapping(new Type(Type.BaseTypes.INT), new Type(Type.BaseTypes.BOOL)), Visibility.NONE));

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

            //add assignment in <participant>Values (<participant>Values[<participantIndex>.associationIndex] = <associationIndex>;
            int finalI = i;
            associations.get(i)
                    .getParticipants().stream()
                    .filter(el -> isMultiInstance(el.getParticipant()))
                    .map(el -> new Statement(decapitalize(el.getParticipant().getName()) + "Values[" + el.getIndex() + "].associationIndex = " + finalI + ";"))
                    .forEach(assignmentStatements::add);
            assignmentStatements.add(new Statement(""));
        }
        assignmentStatements.remove(assignmentStatements.size() - 1);

        //getAssociation function

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

            //add getAssociation function
            for (Participant participant : associationStruct.getParticipants()) {
                String decapParticipantName = decapitalize(participant.getName());
                Function associationGetter = new Function("getAssociation");
                associationGetter.setMarker(Function.Markers.VIEW);
                associationGetter.setVisibility(Visibility.INTERNAL);
                associationGetter.addReturned(new Variable("storage _association", associationStruct));
                associationGetter.addParameter(new Variable(decapParticipantName, new Type(capitalize(participant.getName()))));
                associationGetter.addStatement(new Statement("return associations[getValues(_" + decapParticipantName + ").associationIndex];"));

                contract.addFunction(associationGetter);
            }
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
    /*
    private void parseMessages() {
        Collection<MessageFlow> messageFlows = this.getModel().getModelElementsByType(MessageFlow.class);
        for (MessageFlow messageFlow : messageFlows) {
            if (!isExtern(sourceParticipant(messageFlow)))
                parseSourceMessage(sourceContract(messageFlow), messageFlow.getMessage(), targetParticipant(messageFlow));
            parseTargetMessage(targetContract(messageFlow), messageFlow.getMessage(), sourceParticipant(messageFlow));
        }
    }*/

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
                .filter(this::isContract)
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

    private boolean dealsWithMi(Participant participant) {
        return multiInstanceParticipantsDealingWith(participant).size() > 0;
    }

    private boolean dealsWithMi(Contract contract) {
        return multiInstanceParticipantsDealingWith(getParticipant(contract.getName())).size() > 0;
    }

    private Collection<ChoreographyTask> getChoreographyTasks() {
        return this.getModel().getModelElementsByType(SequenceFlow.class).stream()
                .map(flow -> this.getModel().<ModelElementInstanceImpl>getModelElementById(flow.getAttributeValue("targetRef")))
                .filter(ChoreographyTask::isChoreographyTask)
                .map(node -> new ChoreographyTask(node, this.getModel()))
                .collect(Collectors.toSet());
    }

    private void parseChoreographyTasks() {
        this.getChoreographyTasks().forEach(this::parseChoreographyTask);
    }

    private List<String> eventBasedGatewayDeactivationsId(Collection<SequenceFlow> incomingFlows, String currentId) {
        List<String> result = new LinkedList<>();

        for (SequenceFlow flow : incomingFlows) {
            ModelElementInstance modelElement = getModel().getModelElementById(flow.getSource().getId());
            if (modelElement instanceof EventBasedGateway) {
                flow.getSource().getOutgoing().stream()
                        .map(SequenceFlow::getTarget)
                        .map(BaseElement::getId)
                        .forEach(result::add);
            }
        }

        while (result.remove(currentId)) ;
        return result;
    }

    private void parseChoreographyTask(ChoreographyTask task) {
        Message message = task.getRequest().getMessage();
        int hash = task.getId().hashCode();

        Function setterFunctionTarget;

        //PARSE SOURCE
        if (!isExtern(task.getInitialParticipant())) {
            Function senderFunction = new Function(FunctionParser.nameFunction(message));
            //externals parameters
            Collection<Variable> externals = VariablesParser.parseExtVariables(VariablesParser.variables(message));
            Contract initial = this.contracts.getContract(task.getInitialParticipant());
            externals.stream().forEach(initial::addAttribute);     //add attribute in contract for each external
            //setter function for externals
            if (externals.size() > 0) {
                senderFunction.setVisibility(Visibility.INTERNAL);
                List<ValuedVariable> toBeSet = externals.stream()
                        .map(el -> new ValuedVariable(el.getName(), el.getType(), null))
                        .collect(Collectors.toList());
                Function setterFunction = FunctionParser.parametrizedFunction("set_" + FunctionParser.nameFunction(message), toBeSet);
                //add require and check if participant deals with mi
                if (dealsWithMi(task.getInitialParticipant())) {
                    setterFunction.addStatement(new ForEnableAssociations("" + hash, true));
                } else {
                    setterFunction.addStatement(new Statement("require(isEnabled(" + hash + "), \"Not enabled\");"));
                }

                toBeSet.stream().map(el -> new Statement(el.getName() + " = _" + el.getName() + ";")).forEach(setterFunction::addStatement);
                Collection<Event> setterEvents = EventParser.parseEvents(toBeSet);
                setterEvents.forEach(el -> setterFunction.addStatement(new Statement(el.invocation(new Value("_" + el.getName().replaceFirst("Changed", "")))))); //adds event emit for every parameter
                setterFunction.addModifier(OwnedContract.onlyOwnerModifier());

                setterFunction.addStatement(new Statement(senderFunction.invocation()));
                //TODO check enabled
                initial.addFunction(setterFunction);
                setterEvents.forEach(initial::addEvent);
            }

            setterFunctionTarget = FunctionParser.setterFunction(message);
            List<Value> values = VariablesParser.values(message).stream().map(Value::print).map(VariablesParser::parseExtName).map(Value::new).collect(Collectors.toList());
            Statement sendStatement = new Statement(setterFunctionTarget.invocation(values.toArray(new Value[0])));
            if (!isMultiInstance(task.getParticipantRef())) {
                sendStatement = new Statement(decapitalize(task.getParticipantRef().getName()) + "." + sendStatement.print());
                senderFunction.addStatement(sendStatement);
            } else {
                For forLoop = new For(
                        new ValuedVariable("i", new Type(Type.BaseTypes.UINT), new Value("0")),
                        new Condition("i < associations.length"),
                        new Statement("i++")
                );
                forLoop.addStatement(new IfThenElse(
                        new Condition("isEnabled(" + hash + ", associations[i])"),
                        List.of(
                                new Statement("//TODO SET ABILITATION"),
                                //TODO cannot do associations[i].participant
                                new Statement("associations[i]." + decapitalize(task.getParticipantRef().getName()) + "." + sendStatement.print())
                        )
                ));
                senderFunction.addStatement(forLoop);
            }
            initial.addFunction(senderFunction);
        }

        //PARSE TARGET
        //add attributes
        Contract target = this.contracts.getContract(task.getParticipantRef());
        Collection<? extends Variable> parameters = VariablesParser.variables(message);
        String sourceSetter = null;
        if (isMultiInstance(task.getInitialParticipant())) {
            //creates struct <Participant>Values
            Struct attributesStruct = getIncomingAttributesStruct(target, task.getInitialParticipant());
            parameters.forEach(attributesStruct::addField);
            sourceSetter = "getValues(" + task.getInitialParticipant().getName() + "(msg.sender))";
        } else {
            parameters.forEach(target::addAttribute);
        }

        //add setter function
        Function function = FunctionParser.parametrizedFunction(message);
        if (isExtern(task.getInitialParticipant())) {
            function.addStatement(new Statement("bool enabled = false;"));
            function.addStatement(new For(
                    new ValuedVariable("i", new Type(Type.BaseTypes.UINT), new Value("0")),
                    new Condition("i < associations.length"),
                    new Statement("i++"),
                    List.of(
                            new IfThenElse(
                                    new Condition("isEnabled(" + hash + ", associations[i])"),
                                    List.of(
                                            new Statement("enabled = true;"),
                                            new Statement("//TODO disable this and enable next") //TODO use ForEnableAssociations
                                    )
                            )
                    )
            ));
            function.addStatement(new Statement("require(enabled, \"Not enabled\");"));
            function.getParameters().stream()
                    .map(el -> new Statement(el.getName().replaceFirst("_", "") + " = " + el.getName() + ";"))
                    .forEach(function::addStatement);
        }
        if (isMultiInstance(task.getInitialParticipant())) {
            function.addStatement(new Statement("require(getAssociation(" + task.getInitialParticipant().getName() + "(msg.sender)).activations[" + hash + "], \"Not Enabled\");"));
            //TODO disabilitation current
        } else {

        }
        target.addFunction(function);

        //add events TODO
        Collection<Event> events = EventParser.parseEvents(message);
        if (isMultiInstance(task.getInitialParticipant()))
            events.forEach(el -> el.addParameter(new Variable("_" + decapitalize(task.getInitialParticipant().getName()), new Type(capitalize(task.getInitialParticipant().getName())))));
        events.forEach(target::addEvent);

        events.forEach(el -> function.addStatement(new Statement(el.invocation(eventChangedAttributes(el, task.getInitialParticipant())))));

        //TODO
    }

    private void parseGateways() {
        for (Gateway gateway : this.getModel().getModelElementsByType(Gateway.class)) {
            for (Contract contract : this.contracts) {
                Function gatewayFunction = new Function(gateway.getId());
                Collection<ModelElementInstance> outgoingInstances = gateway.getOutgoing().stream().map(flow -> this.getModel().<ModelElementInstanceImpl>getModelElementById(flow.getAttributeValue("targetRef"))).collect(Collectors.toList());
                for (ModelElementInstance target : outgoingInstances) {
                    if (ChoreographyTask.isChoreographyTask(target)) {
                        ChoreographyTask targetTask = new ChoreographyTask((ModelElementInstanceImpl) target, this.getModel());
                        if (targetTask.getInitialParticipant().equals(getParticipant(contract.getName()))) { //is next source
                            //TODO
                            Collection<Variable> extVariables = VariablesParser.parseExtVariables(VariablesParser.variables(targetTask.getRequest().getMessage()));
                            if (extVariables.size() > 0) {
                                if (dealsWithMi(contract)) {
                                    gatewayFunction.addStatement(new ForEnableAssociations("" + gateway.getId().hashCode(), "" + targetTask.getId().hashCode()));
                                } else {
                                    gatewayFunction.addStatement(new Statement("enable(" + targetTask.hashCode() + ");"));
                                }
                            } else {
                                gatewayFunction.addStatement(new Statement(FunctionParser.baseFunction(targetTask.getRequest().getMessage()).invocation()));
                            }
                        } else if (targetTask.getParticipantRef().equals(getParticipant(contract.getName()))) { //is next target
                            //TODO
                            if (dealsWithMi(contract)) {
                                gatewayFunction.addStatement(new ForEnableAssociations("" + gateway.getId().hashCode(), "" + targetTask.getId().hashCode()));
                            } else {
                                gatewayFunction.addStatement(new Statement("enable(" + targetTask.hashCode() + ");"));
                            }
                        }
                    } else if (target instanceof Gateway) {
                        Gateway targetGateway = (Gateway) target;
                        if (dealsWithMi(contract)) {
                            gatewayFunction.addStatement(new ForEnableAssociations("" + gateway.getId().hashCode(), "" + targetGateway.getId().hashCode()));
                        } else {
                            gatewayFunction.addStatement(new Statement(targetGateway.getId() + "();"));
                        }
                    }
                }
                //gatewayFunction.addStatement(new Statement("//TODO"));
                contract.addFunction(gatewayFunction);
            }
        }
    }

    private List<Statement> activations(Participant current, SequenceFlow flow) {
        List<Statement> statements = new LinkedList<>();
        ModelElementInstance node = this.getModel().getModelElementById(flow.getAttributeValue("targetRef"));
        if (ChoreographyTask.isChoreographyTask(node)) {
            ChoreographyTask destination = new ChoreographyTask((ModelElementInstanceImpl) node, this.getModel());
            if (isExtern(destination.getInitialParticipant())) {
                if (destination.getParticipantRef().equals(current)) {
                    statements.add(new Statement(""));
                }
            }
        } else if (node instanceof Gateway) {

        }

        return null; //TODO
    }
}
