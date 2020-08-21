package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.bpmnelements.ChoreographyTask;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Condition;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Event;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents.*;
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
        addStartFunction();
        addIsReadyFunction();
        initializeEndEvent();
        configureActivations();
        addSetterParticipantFunctions();
        initializeConfigurations();
        initializeAttributes();
        parseChoreographyTasks();
        parseGateways();
        parseEventBasedGateways();
        addIsReadyInvocationInConstructor();

        return this.generateSolidityFile();
    }

    private void initializeAttributes() {
        this.getChoreographyTasks().forEach(this::initializeAttributes);
    }

    private void initializeAttributes(ChoreographyTask task) {
        Message message = task.getRequest().getMessage();
        List<ValuedVariable> variables = VariablesParser.variables(message);
        Contract targetContract = this.contracts.getContract(task.getParticipantRef());

        if (isMultiInstance(task.getInitialParticipant())) {
            //creates struct <Participant>Values
            Struct attributesStruct = getIncomingAttributesStruct(targetContract, task.getInitialParticipant());
            variables.stream().map(el -> new Variable(el.getName(), el.getType())).forEach(attributesStruct::addField);
        } else {
            variables.stream().map(el -> new Variable(el.getName(), el.getType())).forEach(targetContract::addAttribute);
        }

        if (!isExtern(task.getInitialParticipant())) {
            Contract initialContract = this.contracts.getContract(task.getInitialParticipant());
            List<Variable> extVariables = VariablesParser.parseExtVariables(variables);
            extVariables.stream().map(el -> new Variable(el.getName(), el.getType())).forEach(initialContract::addAttribute);
            EventParser.parseEvents(extVariables).forEach(initialContract::addEvent);
            /*
            trueValuedVariables.stream()
                    .filter(el -> el.getValue().print().startsWith("EXT_"))
                    .map(el -> new Variable(el.getValue().print().replaceFirst("EXT_", ""), el.getType()))
                    .forEach(initialContract::addAttribute);
             */
        }

        if (isExtern(task.getInitialParticipant()) || !isMultiInstance(task.getInitialParticipant())) {
            EventParser.parseEvents(variables).forEach(targetContract::addEvent);
        } else {
            EventParser.parseEvents(variables, this.contracts.getContract(task.getInitialParticipant())).forEach(targetContract::addEvent);
        }

    }

    private void initializeEndEvent() {
        for (Contract contract : contracts) {
            ValuedVariable isEnded = new ValuedVariable("isEnded", new Type(Type.BaseTypes.BOOL), new Value("false"));
            isEnded.setComment(new Comment("if contract is ended reaching the end event"));
            Function endEvent = new Function("endEvent");
            endEvent.setComment(new Comment("Ends all definitively", true));
            Modifier isNotEndedModifier = new Modifier("isNotEnded");
            isNotEndedModifier.addStatement(new Statement("require(!isEnded, \"Ended contract\");"));
            isNotEndedModifier.addStatement(new Statement("_;"));
            isNotEndedModifier.setComment(new Comment("Checks whether the contract is definitively ended.\nAllows the modified function to be executed only if this contract is not ended.", true));
            endEvent.addStatement(new Statement("isEnded = true;"));
            //TODO fill function with check that is a contract who calls
            contract.addAttribute(isEnded);
            contract.addModifier(isNotEndedModifier);
            contract.getFunctions().stream()
                    .filter(el -> el.getVisibility().equals(Visibility.EXTERNAL) || el.getVisibility().equals(Visibility.PUBLIC))
                    .forEach(el -> el.addModifier(isNotEndedModifier));
            contract.addFunction(endEvent);
        }
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
                .peek(el -> el.addAttribute(new Variable("activations", activationMapping, Visibility.PUBLIC)))
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
        SolidityFile solidityFile = new SolidityFile(("Translated " + this.getModel().getModel().getModelName()).trim());
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
        Function isReady = new Function("isReady");
        isReady.setComment(new Comment("Checks whether this contract is ready to start.\nThis contract is ready to start only if this contract is configured and all the related contracts to this are ready.", true));
        Function isReadyExt = new Function("isReadyExt");
        isReady.setComment(new Comment("Checks whether the attributes of this contract are all set in order to start.\nChecks only the attributes of this contract.", true));
        Variable returnedVariable = new Variable("_isReady", new Type(Type.BaseTypes.BOOL));
        isReady.addReturned(returnedVariable);
        isReadyExt.addReturned(returnedVariable);
        isReadyExt.setMarker(Function.Markers.VIEW);
        isReadyExt.setVisibility(Visibility.EXTERNAL);

        //check single instance contracts
        singleInstanceContractsDealingWith(contract).stream()
                .map(el -> new IfThenElse(isReadyCondition(el), List.of(new Statement("return false;"))))
                .forEach(isReady::addStatement);
        singleInstanceContractsDealingWith(contract).stream()
                .map(el -> new IfThenElse(isReadyShortCondition(el), List.of(new Statement("return false;"))))
                .forEach(isReadyExt::addStatement);

        //check multiple instance contracts
        multiInstanceParticipantsDealingWith(getParticipant(contract.getName())).stream()
                .filter(this::isContract)
                .map(el -> new For(
                        new ValuedVariable("i", new Type(Type.BaseTypes.UINT), new Value(new Type(Type.BaseTypes.UINT), "0"))
                        , new Condition("i < " + decapitalize(el.getName()) + "Values.length")
                        , new Statement("i++")
                        , List.of(new IfThenElse(isReadyCondition(decapitalize(el.getName()) + "Values[i]." + decapitalize(el.getName())), List.of(new Statement("return false;"))))
                ))
                .forEach(isReady::addStatement);
        multiInstanceParticipantsDealingWith(getParticipant(contract.getName())).stream()
                .filter(this::isContract)
                .map(el -> new For(
                        new ValuedVariable("i", new Type(Type.BaseTypes.UINT), new Value(new Type(Type.BaseTypes.UINT), "0"))
                        , new Condition("i < " + decapitalize(el.getName()) + "Values.length")
                        , new Statement("i++")
                        , List.of(new IfThenElse(isReadyShortCondition(decapitalize(el.getName()) + "Values[i]." + decapitalize(el.getName())), List.of(new Statement("return false;"))))
                ))
                .forEach(isReadyExt::addStatement);

        isReady.addStatement(new Statement("start();"));
        isReady.addStatement(new Statement("return true;"));
        isReadyExt.addStatement(new Statement("return true;"));
        contract.addFunction(isReady);
        contract.addFunction(isReadyExt);
    }

    private void addIsReadyInvocationInConstructor() {
        for (Contract contract : contracts) {
            Constructor constructor;
            if (contract.getConstructor() == null)
                constructor = new Constructor(contract.getName());
            else
                constructor = contract.getConstructor();

            constructor.addStatement(new Comment("Start if is ready"));
            constructor.addStatement(new Statement("isReady();"));

            contract.setConstructor(constructor);
        }
    }

    private void addStartFunction() {
        Event isStartedEvent = new Event("isStartedEvent");
        isStartedEvent.setComment(new Comment("event emitted when this contract starts (one time during the contract life-cycle)"));
        ValuedVariable isStarted = new ValuedVariable("isStarted", new Type(Type.BaseTypes.BOOL), new Value("false"));
        isStarted.setComment(new Comment("if contract is started"));
        ModelElementInstanceImpl firstElement = getModel().getModelElementById(
                getModel().getModelElementsByType(StartEvent.class).stream().findAny().orElseThrow()
                        .getOutgoing().stream().findAny().orElseThrow()
                        .getAttributeValue("targetRef")
        );

        for (Contract contract : contracts) {
            Function startFunction = new Function("start");
            startFunction.setVisibility(Visibility.INTERNAL);
            IfThenElse ifIsStarted = new IfThenElse(new Condition(isStarted.getName() + " == false"));

            if (ChoreographyTask.isChoreographyTask(firstElement)) {
                ChoreographyTask firstTask = new ChoreographyTask(firstElement, getModel());
                if (firstTask.getParticipantRef().getName().equals(contract.getName())) { //is target
                    //if(isExtern(firstTask.getInitialParticipant())){ //initial is extern
                    if (dealsWithMi(contract)) {
                        AssociationsFor associationsFor = new AssociationsFor();
                        Statement enableStatement = new Statement("enable(" + firstTask.getId().hashCode() + ", associations[i]);");
                        associationsFor.addStatement(enableStatement);
                        ifIsStarted.addThenStatement(associationsFor);
                    } else {
                        Statement enableStatement = new Statement("enable(" + firstTask.getId().hashCode() + ");");
                        ifIsStarted.addThenStatement(enableStatement);
                    }
                } else if (firstTask.getParticipantRef().getName().equals(contract.getName())) { //is source
                    boolean hasExternValues = VariablesParser.parseExtVariables(VariablesParser.variables(firstTask.getRequest().getMessage())).size() == 0;

                    if (dealsWithMi(contract)) {
                        AssociationsFor associationsFor = new AssociationsFor();
                        Statement enableStatement = new Statement("enable(" + firstTask.getId().hashCode() + ", associations[i]);");
                        associationsFor.addStatement(enableStatement);
                        ifIsStarted.addThenStatement(associationsFor);
                    } else {
                        Statement enableStatement = new Statement("enable(" + firstTask.getId().hashCode() + ");");
                        ifIsStarted.addThenStatement(enableStatement);
                    }

                    if (!hasExternValues) {
                        ifIsStarted.addThenStatement(new Statement("send_" + FunctionParser.nameFunction(firstTask.getRequest().getMessage()) + "();"));
                    }
                }
            } else if (firstElement instanceof Gateway) {
                Gateway firstGateway = (Gateway) firstElement;
                if (hasGateway(contract, firstGateway)) {
                    ifIsStarted.addThenStatement(new Statement(decapitalize(firstGateway.getId()) + "();"));
                }
            }

            ifIsStarted.addThenStatement(isStarted.assignment(new Value("true")));
            ifIsStarted.addThenStatement(new Statement(isStartedEvent.invocation()));
            startFunction.addStatement(ifIsStarted);
            contract.addAttribute(isStarted);
            contract.addEvent(isStartedEvent);
            contract.addFunction(startFunction);
        }
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
        function.addStatement(new Statement("isReady();"));

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
        function.addStatement(new Statement("isReady();"));

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
        //address(<variableName) == address(0) || !<variableName>.isReadyExt()
        return new Condition(isReadyShortCondition(contractVariableName), "||", new Condition("!" + variableName + ".isReadyExt()"));
        //return new Condition("address(" + variableName + ") == address(0) || !" + variableName + ".isReadyExt()");
    }

    private Condition isReadyShortCondition(Contract contract) {
        return this.isReadyShortCondition(contract.getName());
    }

    private Condition isReadyShortCondition(String contractVariableName) {
        String variableName = decapitalize(contractVariableName);
        //address(<variableName) == address(0) || !<variableName>.isReadyExt()
        return new Condition("address(" + variableName + ") == address(0)");
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

                Variable associationParam = new Variable("_association", associationStruct, Variable.Location.STORAGE);

                Function associationGetter = new Function("getAssociation");
                associationGetter.setMarker(Function.Markers.VIEW);
                associationGetter.setVisibility(Visibility.INTERNAL);
                associationGetter.addReturned(associationParam);
                associationGetter.addParameter(new Variable(decapParticipantName, new Type(capitalize(participant.getName()))));
                associationGetter.addStatement(new Statement("return associations[getValues(_" + decapParticipantName + ").associationIndex];"));
                associationGetter.setComment(new Comment("Retrieves an association from a given " + decapParticipantName, true));

                Function associationToContract = new Function("get" + participant.getName());
                associationToContract.setMarker(Function.Markers.VIEW);
                associationToContract.setVisibility(Visibility.INTERNAL);
                associationToContract.addParameter(associationParam);
                associationToContract.addReturned(new Variable(decapParticipantName, new Type(participant.getName())));
                associationToContract.addStatement(new Statement("return " + decapParticipantName + "Values" + "[_association." + decapParticipantName + "Index" + "]." + decapParticipantName + ";"));
                associationToContract.setComment(new Comment("Retrieves a " + decapParticipantName + " from a given association", true));

                contract.addFunction(associationGetter);
                contract.addFunction(associationToContract);
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

    private String parseOperatorPart(ConditionOperator conditionOperator, Contract actualContract) {
        if (conditionOperator.getContract() == null)
            return conditionOperator.getValue();

        if (conditionOperator.getContract().equals(actualContract) || !isMultiInstance(getParticipant(conditionOperator.getContract().getName()))) {
            return conditionOperator.getValue();
        } else {
            String name = decapitalize(conditionOperator.getContract().getName());
            return name + "Values[associations[i]." + name + "Index]." + conditionOperator.getValue();
        }
    }

    private Condition parseCondition(BinaryCondition binaryCondition, Contract actualContract) {
        return new Condition(parseOperatorPart(binaryCondition.getFirst(), actualContract) + " " + binaryCondition.getComparator() + " " + parseOperatorPart(binaryCondition.getSecond(), actualContract));
    }

    private void parseGateways() {
        Collection<Gateway> gateways = this.getModel().getModelElementsByType(Gateway.class).stream().filter(not(this::isClosing)).collect(Collectors.toSet());
        for (Gateway gateway : gateways) {
            for (Contract contract : this.contracts) {
                Function gatewayFunction = new Function(decapitalize(gateway.getId()));
                gatewayFunction.setComment(new Comment("GATEWAY FUNCTION\nGateway hash id: " + gateway.getId().hashCode() + "\nGateway id: " + gateway.getId(), true));
                Collection<SequenceFlow> outgoingFlows = gateway.getOutgoing();
                Collection<ModelElementInstance> outgoingInstances = gateway.getOutgoing().stream().map(flow -> this.getModel().<ModelElementInstanceImpl>getModelElementById(flow.getAttributeValue("targetRef"))).collect(Collectors.toList());
                String gatewayHash = "" + gateway.getId().hashCode();

                //if gateway is conditional
                boolean isConditional = false;
                if (gateway instanceof ExclusiveGateway)
                    isConditional = true;

                EnableAssociationsFor enableAssociationsFor = null;
                if (dealsWithMi(contract)) {
                    enableAssociationsFor = new EnableAssociationsFor(gatewayHash);
                    gatewayFunction.addStatement(new EnableAssociationsFor.IsEnabledDeclaration());
                    gatewayFunction.addStatement(enableAssociationsFor);
                    gatewayFunction.addStatement(new EnableAssociationsFor.EnabledCycleRequire());
                }

                for (SequenceFlow flow : outgoingFlows) {
                    BinaryCondition condition;
                    IfThenElse ifConditionStatement = null;
                    boolean isInvolved = false; //if this contract is involved in condition
                    if (isConditional) {
                        condition = ConditionsParser.parseCondition(flow, contracts);
                        if (condition.getApplied().equals(contract)) {
                            isInvolved = true;
                            ifConditionStatement = new IfThenElse(parseCondition(condition, contract), List.of());

                            if (dealsWithMi(contract)) enableAssociationsFor.addStatementInIf(ifConditionStatement);
                            else gatewayFunction.addStatement(ifConditionStatement);
                        }
                    }

                    //TODO do nothing if is conditional and not involved
                    if (!(isConditional && !isInvolved)) {
                        Statement toAdd = null;
                        //ModelElementInstance target = this.getModel().<ModelElementInstanceImpl>getModelElementById(flow.getAttributeValue("targetRef"));
                        ModelElementInstance target = getNext(flow);
                        if (ChoreographyTask.isChoreographyTask(target)) { //TODO add enable associations after calls
                            ChoreographyTask targetTask = new ChoreographyTask((ModelElementInstanceImpl) target, this.getModel());
                            if (targetTask.getInitialParticipant().equals(getParticipant(contract.getName()))) { //this is next source
                                Collection<Variable> extVariables = VariablesParser.parseExtVariables(VariablesParser.variables(targetTask.getRequest().getMessage()));
                                if (extVariables.size() > 0) {//enable all associations to accept ext
                                    /*
                                    if (dealsWithMi(contract))
                                        toAdd = new Statement("enable(" + targetTask.getId().hashCode() + ", associations[i]);");
                                    else
                                        toAdd = new Statement("enable(" + targetTask.hashCode() + ");");

                                    if (isInvolved) ifConditionStatement.addThenStatement(toAdd);
                                    else gatewayFunction.addStatement(toAdd);
                                     */
                                    if (dealsWithMi(contract)) {
                                        toAdd = new Statement("enable(" + targetTask.getId().hashCode() + ", associations[i]);");
                                        if (isInvolved) ifConditionStatement.addThenStatement(toAdd);
                                        else enableAssociationsFor.addStatementInIf(toAdd);
                                    } else {
                                        toAdd = new Statement("enable(" + targetTask.getId().hashCode() + ");");
                                        if (isInvolved) ifConditionStatement.addThenStatement(toAdd);
                                        else gatewayFunction.addStatement(toAdd);
                                    }
                                } else {
                                    Function senderFunction = FunctionParser.baseFunction(targetTask.getRequest().getMessage());
                                    senderFunction.setName("send_" + senderFunction.getName());
                                    toAdd = new Statement(senderFunction.invocation());
                                    ValuedVariable conditionEnabling = new ValuedVariable("_enabled_" + senderFunction.getName(), new Type(Type.BaseTypes.BOOL), new Value("false"));
                                    conditionEnabling.setVisibility(Visibility.NONE);
                                    gatewayFunction.addStatement(0, new Statement(conditionEnabling.print()));
                                    if (isInvolved) {
                                        ifConditionStatement.addThenStatement(new Statement("enable(" + targetTask.getId().hashCode() + ", associations[i]);"));
                                        ifConditionStatement.addThenStatement(conditionEnabling.assignment(new Value("true")));
                                        gatewayFunction.addStatement(new IfThenElse(new Condition(conditionEnabling.getName()), List.of(toAdd)));
                                    }
                                    //else gatewayFunction.addStatement(toAdd);
                                }
                            } else if (targetTask.getParticipantRef().equals(getParticipant(contract.getName()))) { //this is next target
                                //TODO
                                if (dealsWithMi(contract)) {
                                    toAdd = new Statement("enable(" + targetTask.getId().hashCode() + ", associations[i]);");
                                    if (isInvolved) ifConditionStatement.addThenStatement(toAdd);
                                    else enableAssociationsFor.addStatementInIf(toAdd);
                                } else {
                                    toAdd = new Statement("enable(" + targetTask.getId().hashCode() + ");");
                                    if (isInvolved) ifConditionStatement.addThenStatement(toAdd);
                                    else gatewayFunction.addStatement(toAdd);
                                }
                            }
                        } else if (target instanceof Gateway) { //TODO to check
                            Gateway targetGateway = (Gateway) target;
                            boolean hasGateway = hasGateway(contract, targetGateway);

                            if (hasGateway) {
                                if (dealsWithMi(contract)) {
                                    toAdd = new Statement("enable(" + targetGateway.getId().hashCode() + ", associations[i]);");
                                    if (isInvolved) ifConditionStatement.addThenStatement(toAdd);
                                    else enableAssociationsFor.addStatementInIf(toAdd);
                                } else {
                                    toAdd = new Statement("enable(" + targetGateway.getId().hashCode() + ");");
                                    if (isInvolved) ifConditionStatement.addThenStatement(toAdd);
                                    else gatewayFunction.addStatement(toAdd);
                                }
                            }
                            multiInstanceContractsDealingWith(getParticipant(contract.getName())).stream()
                                    .filter(el -> hasGateway(el, targetGateway))
                                    .map(Contract::getName)
                                    .map(name -> "get" + capitalize(name) + "(associations[i])." + decapitalize(targetGateway.getId()) + "();")
                                    .map(Statement::new)
                                    .forEach(ifConditionStatement::addThenStatement);

                            ValuedVariable conditionEnabling = new ValuedVariable("_enabled_" + decapitalize(targetGateway.getId()), new Type(Type.BaseTypes.BOOL), new Value("false"));
                            conditionEnabling.setVisibility(Visibility.NONE);
                            IfThenElse ifEnabled = new IfThenElse(new Condition(conditionEnabling.getName()));
                            singleInstanceContractsDealingWith(getParticipant(contract.getName())).stream()
                                    .filter(el -> hasGateway(el, targetGateway))
                                    .map(Contract::getName)
                                    .map(name -> decapitalize(name) + "." + decapitalize(targetGateway.getId()) + "();")
                                    .map(Statement::new)
                                    .forEach(ifEnabled::addThenStatement);
                            if (hasGateway(contract, targetGateway))
                                ifEnabled.addThenStatement(new Statement(decapitalize(targetGateway.getId()) + "();"));

                            //if (ifEnabled.getThenBranch().size() > 0) { //TODO uncomment
                            gatewayFunction.addStatement(0, new Statement(conditionEnabling.print()));
                            gatewayFunction.addStatement(ifEnabled);
                            if (isInvolved)
                                ifConditionStatement.addThenStatement(conditionEnabling.assignment(new Value("true")));
                            //}

                        } else if (target instanceof EndEvent) {
                            for (Contract miContract : multiInstanceContractsDealingWith(getParticipant(contract.getName()))) {
                                String name = capitalize(miContract.getName());
                                if (isInvolved)
                                    ifConditionStatement.addThenStatement(new Statement("get" + name + "(associations[i]).endEvent();"));
                            }

                            ValuedVariable conditionEnabling = new ValuedVariable("_enabled_endEvent", new Type(Type.BaseTypes.BOOL), new Value("false"));
                            conditionEnabling.setVisibility(Visibility.NONE);
                            IfThenElse ifEnabled = new IfThenElse(new Condition(conditionEnabling.getName()));
                            ifConditionStatement.addThenStatement(conditionEnabling.assignment(new Value("true")));
                            gatewayFunction.addStatement(0, new Statement(conditionEnabling.print()));
                            gatewayFunction.addStatement(ifEnabled);
                            for (Contract siContract : singleInstanceContractsDealingWith(contract)) {
                                String name = decapitalize(siContract.getName());
                                toAdd = new Statement(name + ".endEvent();");
                                if (isInvolved) ifEnabled.addThenStatement(toAdd);
                                //else gatewayFunction.addStatement(toAdd);
                            }
                            ifEnabled.addThenStatement(new Statement("endEvent();"));
                        }
                    }
                }

                //gatewayFunction.addStatement(new Statement("//TODO"));
                if (gatewayFunction.getStatements().size() > 0) contract.addFunction(gatewayFunction);
            }
        }
    }

    private void parseEventBasedGateways() {
        for (Gateway gateway : this.getModel().getModelElementsByType(Gateway.class)) {
            for (Contract contract : this.contracts) {
                Function gatewayFunction = new Function(gateway.getId());
                Collection<ModelElementInstance> outgoingInstances = gateway.getOutgoing().stream().map(flow -> this.getModel().<ModelElementInstanceImpl>getModelElementById(flow.getAttributeValue("targetRef"))).collect(Collectors.toList());
                //add notification for event based gateway. If another contract activates an event based gateway
                if (gateway instanceof EventBasedGateway) {
                    Function eventGwNotification = new Function("entered_" + decapitalize(gateway.getId()));
                    eventGwNotification.setComment(new Comment("EVENT BASED GATEWAY DEACTIVATION FUNCTION.\nThis function should be called when a task after an event based gateway is called.\nThis function deactivates all the other tasks of this contract after the gateway.\nGateway id: " + gateway.getId() + ".\n", true));
                    eventGwNotification.setVisibility(Visibility.PUBLIC);

                    if (dealsWithMi(contract)) {
                        For deactivationFor = new For(
                                new ValuedVariable("i", new Type(Type.BaseTypes.UINT), new Value("0")),
                                new Condition("i < associations.length"),
                                new Statement("i++"));
                        for (ModelElementInstance target : outgoingInstances) {
                            if (ChoreographyTask.isChoreographyTask(target)) {
                                ChoreographyTask targetTask = new ChoreographyTask((ModelElementInstanceImpl) target, this.getModel());
                                if (targetTask.getInitialParticipant().equals(getParticipant(contract.getName()))) { //is next source
                                    Collection<Variable> extVariables = VariablesParser.parseExtVariables(VariablesParser.variables(targetTask.getRequest().getMessage()));
                                    if (extVariables.size() > 0) {
                                        deactivationFor.addStatement(new Statement("disable(" + targetTask.getId().hashCode() + ", associations[i]);"));
                                    } else {
                                        //TODO (nothing?)
                                    }
                                } else if (targetTask.getParticipantRef().equals(getParticipant(contract.getName()))) { //is next target
                                    deactivationFor.addStatement(new Statement("disable(" + targetTask.getId().hashCode() + ", associations[i]);"));
                                }
                            } else if (target instanceof Gateway) {
                                Gateway targetGateway = (Gateway) target;
                                deactivationFor.addStatement(new Statement("disable(" + targetGateway.getId().hashCode() + ", associations[i]);"));
                            }
                        }
                        if (deactivationFor.getStatements().size() > 0)
                            eventGwNotification.addStatement(deactivationFor);
                    } else {
                        for (ModelElementInstance target : outgoingInstances) {
                            if (ChoreographyTask.isChoreographyTask(target)) {
                                ChoreographyTask targetTask = new ChoreographyTask((ModelElementInstanceImpl) target, this.getModel());
                                if (targetTask.getInitialParticipant().equals(getParticipant(contract.getName()))) { //is next source
                                    Collection<Variable> extVariables = VariablesParser.parseExtVariables(VariablesParser.variables(targetTask.getRequest().getMessage()));
                                    if (extVariables.size() > 0) {
                                        eventGwNotification.addStatement(new Statement("disable(" + targetTask.getId().hashCode() + ");"));
                                    } else {
                                        //TODO (nothing?)
                                    }
                                } else if (targetTask.getParticipantRef().equals(getParticipant(contract.getName()))) { //is next target
                                    eventGwNotification.addStatement(new Statement("disable(" + targetTask.getId().hashCode() + ");"));
                                }
                            } else if (target instanceof Gateway) {
                                Gateway targetGateway = (Gateway) target;
                                eventGwNotification.addStatement(new Statement("disable(" + targetGateway.getId().hashCode() + ");"));
                            }
                        }
                    }
                    if (eventGwNotification.getStatements().size() > 0) contract.addFunction(eventGwNotification);
                }
            }
        }
    }

    private boolean hasGateway(Contract contract, Gateway gateway) {
        if (gateway instanceof ExclusiveGateway && !isClosing(gateway)) {
            boolean isInvolved = false;
            for (SequenceFlow flow : gateway.getOutgoing()) {
                BinaryCondition condition = ConditionsParser.parseCondition(flow, contracts);
                if (condition.getApplied().equals(contract)) {
                    isInvolved = true;
                }
            }
            return isInvolved;
        }

        for (ModelElementInstanceImpl next : gateway.getOutgoing().stream().map(this::getNext).collect(Collectors.toList())) {
            if (ChoreographyTask.isChoreographyTask(next)) {
                ChoreographyTask nextTask = new ChoreographyTask(next, this.getModel());
                if (contracts.getContract(nextTask.getParticipantRef()).equals(contract))
                    return true;
                if (!isExtern(nextTask.getInitialParticipant()) && contracts.getContract(nextTask.getInitialParticipant()).equals(contract))
                    return true;
            } else if (next instanceof Gateway) {
                //TODO in base alla funzione parse gateways
            } else if (next instanceof EndEvent) {
                return true;
            }
        }
        return false;
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

    //TODO NEW PARSING
    private void parseChoreographyTask(ChoreographyTask task) {
        ModelElementInstanceImpl next = getNext(task);
        ModelElementInstanceImpl previous = getPrevious(task);
        Message message = task.getRequest().getMessage();
        String hash = "" + task.getId().hashCode();
        List<ValuedVariable> variables = VariablesParser.variables(message);
        List<ValuedVariable> notValuedVariables = VariablesParser.parseNotValuedVariables(variables);
        List<ValuedVariable> trueValuedVariables = VariablesParser.parseTrueValuedVariables(variables);
        List<ValuedVariable> cleanedVariables = variables.stream().map(el -> new ValuedVariable(el.getName(), el.getType(), null)).collect(Collectors.toList());
        Contract targetContract = this.contracts.getContract(task.getParticipantRef());
        String messageName = FunctionParser.nameFunction(message);
        Function setterFunction;

        //////////////////////
        /*
        if (ChoreographyTask.isChoreographyTask(next)) {
            System.out.println((new ChoreographyTask(next, this.getModel())).getId());
        }
        if (next instanceof Gateway) {
            System.out.println(((Gateway) next).getId());
        }
        if (next instanceof EndEvent) {
            System.out.println(((EndEvent) next).getId());
        }
         */
        //////////////////////

        if (isExtern(task.getInitialParticipant())) {   //initial is extern
            List<Event> events = EventParser.parseEvents(message);
            String initialName = decapitalize(VariablesParser.parseExtName(task.getInitialParticipant().getName()));

            //events.forEach(targetContract::addEvent);

            setterFunction = FunctionParser.parametrizedFunction(message, notValuedVariables);
            setterFunction.addModifier(OwnedContract.onlyAddressModifier(), new Value(initialName));
            setterFunction.setComment(new Comment("Function called by external participant " + initialName + "\nAssociated task name: " + task.getName() + "\nAssociated task id and hash: " + task.getId() + " | " + hash + "\nAssociated source message: " + message.getName() + "\nParticipants: " + task.getInitialParticipant().getName() + " -> " + task.getParticipantRef().getName(), true));

            //previous event based gateway
            if (previous instanceof EventBasedGateway) {
                EventBasedGateway previousGw = (EventBasedGateway) previous;
                singleInstanceContractsDealingWith(targetContract).stream()
                        .filter(el -> hasGateway(el, previousGw))
                        .map(el -> decapitalize(el.getName()) + ".entered_" + decapitalize(previousGw.getId()) + "();")
                        .map(Statement::new)
                        .forEach(setterFunction::addStatement);
            }

            if (dealsWithMi(targetContract)) {  //deals with mi contracts
                EnableAssociationsFor enableAssociationsFor = new EnableAssociationsFor(hash);

                //previous event based gateway
                if (previous instanceof EventBasedGateway) {
                    EventBasedGateway previousGw = (EventBasedGateway) previous;
                    multiInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                            .filter(el -> hasGateway(el, previousGw))
                            .map(el -> "get" + capitalize(el.getName()) + "(associations[i]).entered_" + decapitalize(previousGw.getId()) + "();")
                            .map(Statement::new)
                            .forEach(enableAssociationsFor::addStatementInIf);
                }

                addAssignments(enableAssociationsFor.getFirstEnabledIf(), variables, events, null, null);

                setterFunction.addStatement(new EnableAssociationsFor.IsEnabledDeclaration());
                setterFunction.addStatement(enableAssociationsFor);
                setterFunction.addStatement(new EnableAssociationsFor.EnabledCycleRequire());

                //TODO check next
                enableAssociationsFor.addStatementInIf(new Comment("TODO call next"));
                //NEXT
                if (ChoreographyTask.isChoreographyTask(next)) {
                    ChoreographyTask nextTask = new ChoreographyTask(next, this.getModel());
                    String nextHash = "" + nextTask.getId().hashCode();
                    if (nextTask.getParticipantRef().getName().equals(targetContract.getName()) || nextTask.getInitialParticipant().getName().equals(targetContract.getName())) { //if this is next target or next source
                        enableAssociationsFor.addStatementInIf(new Statement("enable(" + nextHash + ", associations[i]);"));
                    }
                    if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0 && !isExtern(nextTask.getInitialParticipant())) { //if there are no ext vars
                        if (nextTask.getInitialParticipant().getName().equals(targetContract.getName())) { //if next initial is this
                            setterFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();")); //add calling to send function at end
                        }
                    }

                    if (!nextTask.getInitialParticipant().getName().equals(targetContract.getName()) && !isExtern(nextTask.getInitialParticipant())) { //if next source isn't this and isn't extern
                        Contract nextInitial = this.contracts.getContract(nextTask.getInitialParticipant());
                        Function nextEnablingFunction = new Function("enable_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()));
                        nextEnablingFunction.setVisibility(Visibility.EXTERNAL);

                        if (dealsWithMi(nextInitial)) {
                            nextEnablingFunction.addParameter(new Variable("associationIndex", new Type(Type.BaseTypes.UINT)));
                            nextEnablingFunction.addStatement(new Statement("enable(" + nextHash + ", associations[_associationIndex]);"));
                            if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0)
                                nextEnablingFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();"));

                            if (isMultiInstance(getParticipant(nextInitial.getName()))) { //if next initial is multi instance
                                Statement invocation = new Statement(nextEnablingFunction.invocation("get" + nextInitial.getName() + "(associations[i])", new Value("i")));
                                enableAssociationsFor.addStatementInIf(invocation);
                            } else { //if next initial is single instance
                                Statement invocation = new Statement(nextEnablingFunction.invocation(decapitalize(nextInitial.getName()), new Value("i")));
                                enableAssociationsFor.getFirstEnabledIf().addThenStatement(invocation);
                            }
                        } else {
                            nextEnablingFunction.addStatement(new Statement("enable(" + nextHash + ");"));
                            if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0)
                                nextEnablingFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();"));

                            if (isMultiInstance(getParticipant(nextInitial.getName()))) { //if next initial is multi instance
                                Statement invocationNext = new Statement(nextEnablingFunction.invocation("get" + nextInitial.getName() + "(associations[i])"));
                                enableAssociationsFor.addStatementInIf(invocationNext);
                            } else { //if next initial is single instance
                                Statement invocationNext = new Statement(nextEnablingFunction.invocation(decapitalize(nextInitial.getName())));
                                enableAssociationsFor.getFirstEnabledIf().addThenStatement(invocationNext);
                            }
                        }

                        nextInitial.addFunction(nextEnablingFunction);
                    }
                }
                if (next instanceof Gateway) {
                    Gateway nextGateway = (Gateway) next;
                    String nextHash = "" + nextGateway.getId().hashCode();

                    multiInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                            .filter(el -> hasGateway(el, nextGateway))
                            .map(el -> "get" + el.getName() + "(association[i])." + decapitalize(nextGateway.getId()) + "();")
                            .map(Statement::new)
                            .forEach(enableAssociationsFor::addStatementInIf);

                    singleInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                            .filter(el -> hasGateway(el, nextGateway))
                            .map(el -> decapitalize(el.getName()) + "." + decapitalize(nextGateway.getId()) + "();")
                            .map(Statement::new)
                            .forEach(enableAssociationsFor.getFirstEnabledIf()::addThenStatement);

                    if (hasGateway(targetContract, nextGateway)) {
                        enableAssociationsFor.addStatementInIf(new Statement("enable(" + nextHash + ", associations[i]);"));
                        setterFunction.addStatement(new Statement(decapitalize(nextGateway.getId()) + "();"));
                    }
                }
                if (next instanceof EndEvent) {
                    multiInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                            .map(el -> "get" + el.getName() + "(association[i]).endEvent();")
                            .map(Statement::new)
                            .forEach(enableAssociationsFor::addStatementInIf);

                    singleInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                            .map(el -> decapitalize(el.getName()) + ".endEvent();")
                            .map(Statement::new)
                            .forEach(enableAssociationsFor.getFirstEnabledIf()::addThenStatement);


                    setterFunction.addStatement(new Statement("endEvent();"));
                }
                //END-NEXT
            } else {  //does not deal with mi contracts
                setterFunction.addStatement(new HashEnableRequire(hash));
                addAssignments(setterFunction, variables, events, null, null);

                //TODO check next
                //NEXT
                if (ChoreographyTask.isChoreographyTask(next)) {
                    ChoreographyTask nextTask = new ChoreographyTask(next, this.getModel());
                    String nextHash = "" + nextTask.getId().hashCode();
                    if (nextTask.getParticipantRef().getName().equals(targetContract.getName()) || nextTask.getInitialParticipant().getName().equals(targetContract.getName())) { //if this is next target or next source
                        setterFunction.addStatement(new Statement("enable(" + nextHash + ");"));
                    }
                    if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0 && !isExtern(nextTask.getInitialParticipant())) { //if there are no ext vars
                        if (nextTask.getInitialParticipant().getName().equals(targetContract.getName())) { //if next initial is this
                            setterFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();")); //add calling to send function at end
                        }
                    }

                    if (!nextTask.getInitialParticipant().getName().equals(targetContract.getName()) && !isExtern(nextTask.getInitialParticipant())) { //if next source isn't this and isn't extern
                        Contract nextInitial = this.contracts.getContract(nextTask.getInitialParticipant());
                        Function nextEnablingFunction = new Function("enable_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()));
                        nextEnablingFunction.setVisibility(Visibility.EXTERNAL);

                        if (dealsWithMi(nextInitial)) {
                            if (isMultiInstance(getParticipant(targetContract.getName()))) { //this target is multi instance
                                nextEnablingFunction.addStatement(new Statement("enable(" + nextHash + ", getAssociation(" + targetContract.getName() + "(msg.sender));"));
                                if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0)
                                    nextEnablingFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();"));

                                if (isMultiInstance(getParticipant(nextInitial.getName()))) { //if next initial is multi instance
                                    //TODO illegal
                                    throw new IllegalStateException();
                                } else { //if next initial is single instance
                                    Statement invocationNext = new Statement(nextEnablingFunction.invocation(decapitalize(nextInitial.getName())));
                                    setterFunction.addStatement(invocationNext);
                                }
                            } else { //this target is single instance
                                //TODO illegal
                                throw new IllegalStateException();
                            }
                        } else {
                            nextEnablingFunction.addStatement(new Statement("enable(" + nextHash + ");"));
                            if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0)
                                nextEnablingFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();"));

                            if (isMultiInstance(getParticipant(nextInitial.getName()))) { //if next initial is multi instance
                                //TODO illegal
                                throw new IllegalStateException();
                            } else { //if next initial is single instance
                                Statement invocation = new Statement(nextEnablingFunction.invocation(decapitalize(nextInitial.getName())));
                                setterFunction.addStatement(invocation);
                            }
                        }

                        nextInitial.addFunction(nextEnablingFunction);
                    }
                }
                if (next instanceof Gateway) {
                    Gateway nextGateway = (Gateway) next;
                    String nextHash = "" + nextGateway.getId().hashCode();

                    singleInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                            .filter(el -> hasGateway(el, nextGateway))
                            .map(el -> decapitalize(el.getName()) + "." + decapitalize(nextGateway.getId()) + "();")
                            .map(Statement::new)
                            .forEach(setterFunction::addStatement);

                    if (hasGateway(targetContract, nextGateway)) {
                        setterFunction.addStatement(new Statement("enable(" + nextHash + ");"));
                        setterFunction.addStatement(new Statement(decapitalize(nextGateway.getId()) + "();"));
                    }
                }
                if (next instanceof EndEvent) {
                    singleInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                            .map(el -> decapitalize(el.getName()) + ".endEvent();")
                            .map(Statement::new)
                            .forEach(setterFunction::addStatement);

                    setterFunction.addStatement(new Statement("endEvent();"));
                }
                //END-NEXT
            }

            if (previous instanceof EventBasedGateway)
                setterFunction.addStatement(new Statement("entered_" + decapitalize(((EventBasedGateway) previous).getId()) + "();"));

            //TODO check next out of for
            targetContract.addFunction(setterFunction);
        } else {    //initial is not extern
            Contract initialContract = this.contracts.getContract(task.getInitialParticipant());
            Function senderFunction = new Function("send_" + messageName);
            senderFunction.setComment(new Comment("Sender function from this contract to " + targetContract.getName() + "\nAssociated task name: " + task.getName() + "\nAssociated task id and hash: " + task.getId() + " | " + hash + "\nAssociated source message: " + message.getName() + "\nParticipants: " + task.getInitialParticipant().getName() + " -> " + task.getParticipantRef().getName(), true));

            setterFunction = FunctionParser.parametrizedFunction(message);
            setterFunction.setComment(new Comment("Setter function for values provided by a contract\nAssociated task name: " + task.getName() + "\nAssociated task id and hash: " + task.getId() + " | " + hash + "\nAssociated source message: " + message.getName() + "\nParticipants: " + task.getInitialParticipant().getName() + " -> " + task.getParticipantRef().getName(), true));

            //sender function
            List<ValuedVariable> externVariables = VariablesParser.parseExtValuedVariables(variables);
            if (VariablesParser.parseExtVariables(variables).size() > 0) {  //if there are extern variables
                Function setterExtValuesFunction = FunctionParser.parametrizedFunction("set_" + messageName, externVariables);
                setterExtValuesFunction.setComment(new Comment("Setter function for external values\nAssociated task name: " + task.getName() + "\nAssociated task id and hash: " + task.getId() + " | " + hash + "\nAssociated source message: " + message.getName() + "\nParticipants: " + task.getInitialParticipant().getName() + " -> " + task.getParticipantRef().getName(), true));

                List<Event> extVariablesEvents = EventParser.parseEvents(externVariables);

                //previous event based gateway
                if (previous instanceof EventBasedGateway) {
                    EventBasedGateway previousGw = (EventBasedGateway) previous;
                    singleInstanceContractsDealingWith(targetContract).stream()
                            .filter(el -> hasGateway(el, previousGw))
                            .map(el -> decapitalize(el.getName()) + ".entered_" + decapitalize(previousGw.getId()) + "();")
                            .map(Statement::new)
                            .forEach(setterExtValuesFunction::addStatement);
                }

                //extVariablesEvents.forEach(initialContract::addEvent);

                if (dealsWithMi(initialContract)) {  //if sender deals with mi and has extern vars to send
                    EnableAssociationsFor enableAssociationsFor = new EnableAssociationsFor(hash);

                    addAssignments(enableAssociationsFor.getFirstEnabledIf(), externVariables, extVariablesEvents, null, null);

                    //previous event based gateway
                    if (previous instanceof EventBasedGateway) {
                        EventBasedGateway previousGw = (EventBasedGateway) previous;
                        multiInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                                .filter(el -> hasGateway(el, previousGw))
                                .map(el -> "get" + capitalize(el.getName()) + "(associations[i]).entered_" + decapitalize(previousGw.getId()) + "();")
                                .map(Statement::new)
                                .forEach(enableAssociationsFor::addStatementInIf);
                    }

                    setterExtValuesFunction.addStatement(new EnableAssociationsFor.IsEnabledDeclaration());
                    setterExtValuesFunction.addStatement(enableAssociationsFor);
                    setterExtValuesFunction.addStatement(new EnableAssociationsFor.EnabledCycleRequire());
                } else { //if sender does not deal with mi and has extern vars to send
                    setterExtValuesFunction.addStatement(new HashEnableRequire(hash));
                    setterExtValuesFunction.addStatement(new Statement("disable(" + hash + ");"));
                    addAssignments(setterExtValuesFunction, externVariables, extVariablesEvents, null, null);
                }

                //previous event based gateway
                if (previous instanceof EventBasedGateway)
                    setterExtValuesFunction.addStatement(new Statement("entered_" + decapitalize(((EventBasedGateway) previous).getId()) + "();"));

                setterExtValuesFunction.addStatement(new Comment("call sender function"));
                setterExtValuesFunction.addStatement(new Statement(senderFunction.invocation()));
                initialContract.addFunction(setterExtValuesFunction);
                senderFunction.setVisibility(Visibility.INTERNAL);
            }

            List<Value> sendValues = variables.stream().map(el -> el.getValue() == null ? new Value(el.getName()) : el.getValue()).collect(Collectors.toList());
            String sendValuesString = "";
            for (Value value : sendValues)
                sendValuesString += value.print() + ", ";
            if (sendValues.size() > 0) sendValuesString = sendValuesString.substring(0, sendValuesString.length() - 2);

            //setter function
            if (isMultiInstance(task.getInitialParticipant())) { //if initial is mi
                List<Event> events = EventParser.parseEvents(variables, initialContract);
                //events.forEach(targetContract::addEvent);

                setterFunction.addStatement(new Comment("TODO check enabling or if the sender is the correct contract")); //TODO
                String senderContract = capitalize(initialContract.getName()) + "(msg.sender)";
                String senderContractValues = "getValues(" + senderContract + ")";

                setterFunction.addStatement(new Statement("Association storage association = getAssociation(" + senderContract + ");"));
                addAssignments(setterFunction, cleanedVariables, events, senderContractValues, senderContract);
                setterFunction.addStatement(new Comment("TODO call next (initial is mi)"));

                //TODO check next
                //NEXT //TODO probably all wrong
                if (ChoreographyTask.isChoreographyTask(next)) {
                    ChoreographyTask nextTask = new ChoreographyTask(next, this.getModel());
                    String nextHash = "" + nextTask.getId().hashCode();
                    if (nextTask.getParticipantRef().getName().equals(targetContract.getName()) || nextTask.getInitialParticipant().getName().equals(targetContract.getName())) { //if this is next target or next source
                        setterFunction.addStatement(new Statement("enable(" + nextHash + ", association);"));
                    }
                    if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0 && !isExtern(nextTask.getInitialParticipant())) { //if there are no ext vars
                        if (nextTask.getInitialParticipant().getName().equals(targetContract.getName())) { //if next initial is this
                            setterFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();")); //add calling to send function at end
                        }
                    }

                    if (!nextTask.getInitialParticipant().getName().equals(targetContract.getName()) && !isExtern(nextTask.getInitialParticipant())) { //if next source isn't this and isn't extern
                        Contract nextInitial = this.contracts.getContract(nextTask.getInitialParticipant());
                        Function nextEnablingFunction = new Function("enable_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()));
                        nextEnablingFunction.setVisibility(Visibility.EXTERNAL);

                        if (dealsWithMi(nextInitial)) {
                            if (isMultiInstance(getParticipant(targetContract.getName()))) { //this target is multi instance
                                nextEnablingFunction.addStatement(new Statement("enable(" + nextHash + ", getAssociation(" + targetContract.getName() + "(msg.sender));"));
                                if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0)
                                    nextEnablingFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();"));

                                if (isMultiInstance(getParticipant(nextInitial.getName()))) { //if next initial is multi instance
                                    //TODO illegal
                                    throw new IllegalStateException();
                                } else { //if next initial is single instance
                                    Statement invocationNext = new Statement(nextEnablingFunction.invocation(decapitalize(nextInitial.getName())));
                                    setterFunction.addStatement(invocationNext);
                                }
                            } else { //this target is single instance
                                //TODO illegal
                                throw new IllegalStateException();
                            }
                        } else {
                            nextEnablingFunction.addStatement(new Statement("enable(" + nextHash + ");"));
                            if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0)
                                nextEnablingFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();"));

                            if (isMultiInstance(getParticipant(nextInitial.getName()))) { //if next initial is multi instance
                                //TODO illegal
                                throw new IllegalStateException();
                            } else { //if next initial is single instance
                                Statement invocation = new Statement(nextEnablingFunction.invocation(decapitalize(nextInitial.getName())));
                                setterFunction.addStatement(invocation);
                            }
                        }

                        nextInitial.addFunction(nextEnablingFunction);
                    }
                }
                if (next instanceof Gateway) {
                    Gateway nextGateway = (Gateway) next;
                    String nextHash = "" + nextGateway.getId().hashCode();

                    multiInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                            .filter(el -> hasGateway(el, nextGateway))
                            .map(el -> "get" + el.getName() + "(association)." + decapitalize(nextGateway.getId()) + "();")
                            .map(Statement::new)
                            .forEach(setterFunction::addStatement);

                    singleInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                            .filter(el -> hasGateway(el, nextGateway))
                            .map(el -> decapitalize(el.getName()) + "." + decapitalize(nextGateway.getId()) + "();")
                            .map(Statement::new)
                            .forEach(setterFunction::addStatement);

                    if (hasGateway(targetContract, nextGateway)) {
                        setterFunction.addStatement(new Statement("enable(" + nextHash + ", association);"));
                        setterFunction.addStatement(new Statement(decapitalize(nextGateway.getId()) + "();"));
                    }
                }
                if (next instanceof EndEvent) {
                    multiInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                            .map(el -> "get" + el.getName() + "(association).endEvent();")
                            .map(Statement::new)
                            .forEach(setterFunction::addStatement);

                    singleInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                            .map(el -> decapitalize(el.getName()) + ".endEvent();")
                            .map(Statement::new)
                            .forEach(setterFunction::addStatement);

                    setterFunction.addStatement(new Statement("endEvent();"));
                }
                //END-NEXT
            } else { //if initial is not mi
                List<Event> events = EventParser.parseEvents(message);
                setterFunction.addModifier(OwnedContract.onlyAddressModifier(), new Value("address(" + decapitalize(initialContract.getName()) + ")"));
                setterFunction.addStatement(new Comment("TODO check enabling(?)")); //TODO

                addAssignments(setterFunction, cleanedVariables, events, null, null);
                setterFunction.addStatement(new Comment("TODO call next (initial is not mi)"));

                //TODO check next
                //NEXT
                if (!dealsWithMi(targetContract)) {
                    if (ChoreographyTask.isChoreographyTask(next)) {
                        ChoreographyTask nextTask = new ChoreographyTask(next, this.getModel());
                        String nextHash = "" + nextTask.getId().hashCode();
                        if (nextTask.getParticipantRef().getName().equals(targetContract.getName()) || nextTask.getInitialParticipant().getName().equals(targetContract.getName())) { //if this is next target or next source
                            setterFunction.addStatement(new Statement("enable(" + nextHash + ");"));
                        }
                        if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0 && !isExtern(nextTask.getInitialParticipant())) { //if there are no ext vars
                            if (nextTask.getInitialParticipant().getName().equals(targetContract.getName())) { //if next initial is this
                                setterFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();")); //add calling to send function at end
                            }
                        }

                        if (!nextTask.getInitialParticipant().getName().equals(targetContract.getName()) && !isExtern(nextTask.getInitialParticipant())) { //if next source isn't this and isn't extern
                            Contract nextInitial = this.contracts.getContract(nextTask.getInitialParticipant());
                            Function nextEnablingFunction = new Function("enable_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()));
                            nextEnablingFunction.setVisibility(Visibility.EXTERNAL);

                            if (dealsWithMi(nextInitial)) {
                                if (isMultiInstance(getParticipant(targetContract.getName()))) { //this target is multi instance
                                    nextEnablingFunction.addStatement(new Statement("enable(" + nextHash + ", getAssociation(" + targetContract.getName() + "(msg.sender));"));
                                    if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0)
                                        nextEnablingFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();"));

                                    if (isMultiInstance(getParticipant(nextInitial.getName()))) { //if next initial is multi instance
                                        //TODO illegal
                                        throw new IllegalStateException();
                                    } else { //if next initial is single instance
                                        Statement invocationNext = new Statement(nextEnablingFunction.invocation(decapitalize(nextInitial.getName())));
                                        setterFunction.addStatement(invocationNext);
                                    }
                                } else { //this target is single instance
                                    //TODO illegal
                                    throw new IllegalStateException();
                                }
                            } else {
                                nextEnablingFunction.addStatement(new Statement("enable(" + nextHash + ");"));
                                if (VariablesParser.parseExtVariables(VariablesParser.variables(nextTask.getRequest().getMessage())).size() == 0)
                                    nextEnablingFunction.addStatement(new Statement("send_" + FunctionParser.nameFunction(nextTask.getRequest().getMessage()) + "();"));

                                if (isMultiInstance(getParticipant(nextInitial.getName()))) { //if next initial is multi instance
                                    //TODO illegal
                                    throw new IllegalStateException();
                                } else { //if next initial is single instance
                                    Statement invocation = new Statement(nextEnablingFunction.invocation(decapitalize(nextInitial.getName())));
                                    setterFunction.addStatement(invocation);
                                }
                            }

                            nextInitial.addFunction(nextEnablingFunction);
                        }
                    }
                    if (next instanceof Gateway) {
                        Gateway nextGateway = (Gateway) next;
                        String nextHash = "" + nextGateway.getId().hashCode();

                        singleInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                                .filter(el -> hasGateway(el, nextGateway))
                                .map(el -> decapitalize(el.getName()) + "." + decapitalize(nextGateway.getId()) + "();")
                                .map(Statement::new)
                                .forEach(setterFunction::addStatement);

                        if (hasGateway(targetContract, nextGateway)) {
                            setterFunction.addStatement(new Statement("enable(" + nextHash + ");"));
                            setterFunction.addStatement(new Statement(decapitalize(nextGateway.getId()) + "();"));
                        }
                    }
                    if (next instanceof EndEvent) {
                        singleInstanceContractsDealingWith(getParticipant(targetContract.getName())).stream()
                                .map(el -> decapitalize(el.getName()) + ".endEvent();")
                                .map(Statement::new)
                                .forEach(setterFunction::addStatement);

                        setterFunction.addStatement(new Statement("endEvent();"));
                    }
                } else {
                    throw new IllegalStateException(); //TODO illegal (?)
                }
                //END-NEXT
            }

            //sender function
            if (isMultiInstance(task.getParticipantRef())) {  //if target is mi
                senderFunction.addStatement(new Comment("TODO check sender (not if is internal)"));
                EnableAssociationsFor enableAssociationsFor = new EnableAssociationsFor(hash);
                //send
                Statement sendStatement = new Statement("get" + targetContract.getName() + "(associations[i])." + messageName + "(" + sendValuesString + ");");
                enableAssociationsFor.addStatementInIf(sendStatement);

                senderFunction.addStatement(new EnableAssociationsFor.IsEnabledDeclaration());
                senderFunction.addStatement(enableAssociationsFor);
                senderFunction.addStatement(new EnableAssociationsFor.EnabledCycleRequire());
            } else { //if target is not mi
                String invocation = setterFunction.invocation(decapitalize(targetContract.getName()), VariablesParser.callingValues(variables));
                senderFunction.addStatement(new Statement(invocation));
            }

            initialContract.addFunction(senderFunction);
        }
        targetContract.addFunction(setterFunction);
    }

    private void addAssignments(StatementContainer container, List<ValuedVariable> variables, List<Event> events, String assignmentSource, String eventSource) {
        List<ValuedVariable> notValuedVariables = VariablesParser.parseNotValuedVariables(variables);
        List<ValuedVariable> trueValuedVariables = VariablesParser.parseTrueValuedVariables(variables);

        if (notValuedVariables.size() > 0) container.addStatement(new Comment("set all received values"));
        notValuedVariables.stream().map(el -> el.getName().startsWith("_") ? el.getName().replaceFirst("_", "") : el.getName()).map(el -> new Statement((assignmentSource == null ? "" : (assignmentSource + ".")) + el + " = _" + VariablesParser.parseExtName(el) + ";")).forEach(container::addStatement);
        if (trueValuedVariables.size() > 0) container.addStatement(new Comment("set all predefined values"));
        trueValuedVariables.stream().map(el -> new Statement((assignmentSource == null ? "" : (assignmentSource + ".")) + el.getName() + " = " + el.getValue().print().replaceFirst("EXT", "") + ";")).forEach(container::addStatement);
        if (events.size() > 0) container.addStatement(new Comment("emit all changed values events"));
        if (eventSource == null) {
            events.stream()
                    .map(el -> el.invocation(new Value(el.getParameters().get(0).getName().replaceFirst("_", ""))))
                    .map(Statement::new)
                    .forEach(container::addStatement);
        } else {
            events.stream()
                    .map(el -> el.invocation(
                            new Value(el.getParameters().get(0).getName()),
                            new Value(eventSource)))
                    .map(Statement::new)
                    .forEach(container::addStatement);
        }
    }

    private boolean isClosing(Gateway gateway) {
        return gateway.getOutgoing().size() == 1;
    }

    private ModelElementInstanceImpl getNext(ChoreographyTask task) {
        if (task.getOutgoing().size() > 1) throw new IllegalArgumentException();

        return getNext(task.getOutgoing().stream().findFirst().orElseThrow());
    }

    private ModelElementInstanceImpl getNext(Gateway gateway) {
        if (!isClosing(gateway)) throw new IllegalArgumentException();

        return getNext(gateway.getOutgoing().stream().findFirst().orElseThrow());
    }

    private ModelElementInstanceImpl getNext(SequenceFlow flow) {
        boolean done = false;
        ModelElementInstanceImpl next;
        do {
            next = this.getModel().getModelElementById(flow.getAttributeValue("targetRef"));
            if (next instanceof Gateway) {
                Gateway nextGw = (Gateway) next;
                if (!isClosing(nextGw))
                    done = true;
                else
                    flow = nextGw.getOutgoing().stream().findFirst().orElseThrow();
            } else if (ChoreographyTask.isChoreographyTask(next))
                done = true;
            else if (next instanceof EndEvent)
                done = true;
        } while (!done);

        return next;
    }

    private ModelElementInstanceImpl getPrevious(ChoreographyTask task) {
        if (task.getIncoming().size() != 1) throw new IllegalArgumentException();

        return this.getModel().getModelElementById(
                task.getIncoming().stream()
                        .findAny().orElseThrow()
                        .getAttributeValue("sourceRef")
        );
    }
}
