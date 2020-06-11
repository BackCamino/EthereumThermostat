package com.project.Demo;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.camunda.bpm.model.bpmn.Bpmn;
import org.camunda.bpm.model.bpmn.BpmnModelInstance;
import org.camunda.bpm.model.bpmn.instance.EndEvent;
import org.camunda.bpm.model.bpmn.instance.EventBasedGateway;
import org.camunda.bpm.model.bpmn.instance.ExclusiveGateway;
import org.camunda.bpm.model.bpmn.instance.FlowNode;
import org.camunda.bpm.model.bpmn.instance.Gateway;
import org.camunda.bpm.model.bpmn.instance.Message;
import org.camunda.bpm.model.bpmn.instance.MessageFlow;
import org.camunda.bpm.model.bpmn.instance.ParallelGateway;
import org.camunda.bpm.model.bpmn.instance.Participant;
import org.camunda.bpm.model.bpmn.instance.SequenceFlow;
import org.camunda.bpm.model.xml.impl.instance.ModelElementInstanceImpl;
import org.camunda.bpm.model.xml.instance.ModelElementInstance;
import org.joda.time.format.ISOPeriodFormat;

public class Translator {

	private BpmnModelInstance modelInstance;
	private Collection<FlowNode> allNodes;
	private ArrayList<String> participants;
	private ArrayList<String> participantsWithoutDuplicates;
	private Collection<Message> messages;
	private Collection<MessageFlow> messageFlows;
	private ArrayList<String> externParticipants;
	private ArrayList<String> externParticipantsWithoutDuplicates;
	private Collection<ChoreographyTask> chorTasks;
	private Collection<Gateway> gateways;
	private String solidityFile;

	public static void main(String[] args) {
		Translator translator = new Translator();
		File bpnmFile = new File("./diagram.bpmn"); // ./model.bpmn ./test_diagram.bpmn
		try {
			translator.run(bpnmFile);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public Translator() {
		participants = new ArrayList<String>();
		participantsWithoutDuplicates = new ArrayList<String>();
		externParticipants = new ArrayList<String>();
		externParticipantsWithoutDuplicates = new ArrayList<String>();
		chorTasks = new HashSet<>();
	}

	public void run(File bpmnFile) throws Exception {
		Translator translator = new Translator();
		translator.readFile(bpmnFile);
		solidityFile = translator.init();
		System.out.println(solidityFile);
		// translator.writeFile();
	}

	private String init() {
		String intro = "pragma solidity ^0.6.9;\n";
		intro += "\nenum State {DISABLED, ENABLED}\n";
		for (String participant : participantsWithoutDuplicates) {
			intro += "\ncontract " + participant + " {" 
					+ getContractParams(participant) 
					+ getAddresses(participant)
					+ getContractsVariables(participant) +
					// getOutgoingMessagesFunctions(participant)+
					getEvents(participant) +
					// getSetterFunctions(participant) +
					getTaskFunctions(participant) + 
					getGatewayFunctions(participant) +
					"}\n";
		}
		return intro;
	}

	public void readFile(File bpFile) throws IOException {
		modelInstance = Bpmn.readModelFromFile(bpFile);
		allNodes = modelInstance.getModelElementsByType(FlowNode.class);
		getParticipants();
		getMessages();
		getChoreographyTasks();
		getGateways();
	}

	private void writeFile() throws IOException, Exception {
		FileWriter wChor = new FileWriter(
				new File(/* Project patch + */ File.separator + "resources" + File.separator /* + File name + .sol */));
		BufferedWriter bChor = new BufferedWriter(wChor);
		bChor.write(solidityFile);
		bChor.flush();
		bChor.close();
	}

	private void getMessages() {
		messages = modelInstance.getModelElementsByType(Message.class);
		messageFlows = modelInstance.getModelElementsByType(MessageFlow.class);
	}

	private void getGateways() {
		gateways = modelInstance.getModelElementsByType(Gateway.class);
	}

	/**
	 * Retrieves the parameters of the incoming messages variables
	 * 
	 * @param contractName
	 * @return
	 */
	private String getContractParams(String contractName) {
		String params = "\n";
		Set<Variable> variables = new HashSet<>();
		for (MessageFlow mFlow : messageFlows) {
			if (contractName.compareTo(getParticipant(mFlow.getTarget().getId()).getName()) == 0)
				variables.addAll(getVariables(mFlow.getMessage()));
		}
		// define attributes
		for (Variable v : variables) {
			params += "    " + v.getType() + " " + v.getName() + ";\n";
		}
		return params;
	}

	/**
	 * Retrieves the events based on the variables set by incoming messages
	 * 
	 * @param contractName
	 * @return
	 */
	private String getEvents(String contractName) {
		String events = "\n";
		for (MessageFlow mFlow : messageFlows) {
			if (contractName.compareTo(getParticipant(mFlow.getTarget().getId()).getName()) == 0) {
				Collection<Variable> variables = getVariables(mFlow.getMessage());

				// define events for changing attributes
				for (Variable v : variables) {
					events += "    event " + v.getName() + "Changed (" + v.getType() + " _" + v.getName() + ");\n";
				}
			}
		}
		return events;
	}

	private Participant getParticipant(String partId) {
		return modelInstance.getModelElementById(partId);
	}

	private void getParticipants() {
		Collection<Participant> parti = modelInstance.getModelElementsByType(Participant.class);
		for (Participant p : parti) {
			if (!isExtern(p)) {
				participants.add(p.getName());
			} else {
				externParticipants.add(p.getName());
			}
		}
		participantsWithoutDuplicates = new ArrayList<>(new HashSet<>(participants));
		externParticipantsWithoutDuplicates = new ArrayList<>(new HashSet<>(externParticipants));
	}

	/**
	 * Retrieves setter functions based on the parameters in the incoming messages
	 * 
	 * @param partId
	 * @return
	 */
	private String getSetterFunctions(String partId) {
		// TODO add access control
		String functions = "\n";
		for (MessageFlow msgFlow : messageFlows) {
			if (partId.compareTo(getParticipant(msgFlow.getTarget().getId()).getName()) == 0) {
				Collection<Variable> variables = getVariables(msgFlow.getMessage());

				functions += "    function " + msgFlow.getMessage().getName().split("\\(")[0] + " (";
				Iterator<Variable> iter = variables.iterator();
				while (iter.hasNext()) {
					Variable v = iter.next();
					functions += v.getType() + " _" + v.getName();
					if (iter.hasNext())
						functions += ", ";
				}
				functions += ") public {\n";

				for (Variable v : variables) {
					functions += "        " + v.getName() + " = _" + v.getName() + ";\n";
					functions += "        emit " + v.getName() + "Changed" + " (" + v.getName() + ");\n";
				}

				functions += "    }\n\n";
			}
		}
		return functions;
	}

	/**
	 * Retrieves functions that call methods on the others contracts based on the
	 * outgoing messages
	 * 
	 * @param partId
	 * @return
	 */
	private String getOutgoingMessagesFunctions(String partId) {
		String functions = "\n";
		for (MessageFlow msgFlow : messageFlows) {
			// TODO check if target participant is not extern
			if (partId.compareTo(getParticipant(msgFlow.getSource().getId()).getName()) == 0) {
				Collection<Variable> variables = getVariables(msgFlow.getMessage());

				String funName = msgFlow.getMessage().getName().split("\\(")[0];
				functions += "    function " + funName + " () private {\n";

				for (Variable v : variables) {
					String participant = getParticipant(msgFlow.getTarget().getId()).getName();
					String participantReference = participant.substring(0, 1).toLowerCase() + participant.substring(1);
					functions += "        " + participantReference + "." + funName + "(" + v.getValue() + ");\n";
				}

				functions += "    }\n\n";
			}
		}
		return functions;
	}

	/**
	 * Retrieves the attributes associated with the other contracts
	 * 
	 * @param partId
	 * @return
	 */
	private String getContractsVariables(String partId) {
		// TODO check if there are no messages between the considered contract and the
		// others
		String contracts = "\n";
		Collection<Variable> contractsVariables = new HashSet<>();

		// variable declarations
		for (String participant : participantsWithoutDuplicates) {
			if (partId.compareTo(participant) != 0) {
				Variable variable = new Variable(participant.substring(0, 1).toUpperCase() + participant.substring(1),
						participant.substring(0, 1).toLowerCase() + participant.substring(1));
				contractsVariables.add(variable);
				contracts += "    " + variable.getType() + " " + variable.getName() + ";\n";
			}
		}
		contracts += "\n";

		// variable assignment, setters
		for (Variable v : contractsVariables) {
			contracts += "    function set" + v.getType() + " (address _" + v.getName() + "Address) {\n";
			contracts += "        " + v.getName() + " = " + v.getType() + " (_" + v.getName() + "Address);\n";
			contracts += "    }\n\n";
		}

		// function that checks if all the addresses are provided
		// TODO add check only owner
		contracts += "    function isReady() public returns(bool) {\n";
		if (contractsVariables.isEmpty())
			contracts += "        return true;\n";
		else {
			contracts += "        if (";

			Iterator<Variable> iterator = contractsVariables.iterator();
			while (iterator.hasNext()) {
				Variable v = iterator.next();
				contracts += "address(" + v.getName() + ") != address(0)";
				if (iterator.hasNext())
					contracts += " && ";
			}
			contracts += ")\n            return true;\n        else\n            return false;\n";
		}
		contracts += "    }\n\n";

		return contracts;
	}

	/**
	 * Retrieves variables from a message string
	 * 
	 * @param msg
	 * @return
	 */
	private Collection<Variable> getVariables(Message msg) {
		HashSet<Variable> res = new HashSet<>();

		for (String var : msg.getName().split("\\(")[1].replace(")", "").trim().split("\\,")) {
			String value = null;
			String[] varAndValue = var.trim().split("=");
			if (varAndValue.length == 2)
				value = varAndValue[1].trim();
			String[] varParts = varAndValue[0].trim().split(" ");
			res.add(new Variable(varParts[0], varParts[1], value));
		}
		return res;
	}

	private String getAddresses(String partId) {
		String result_addresses = "\n";
		ArrayList<String> addresses = new ArrayList<String>();
		ArrayList<String> addressesWithoutDuplicates = new ArrayList<String>();

		for (ChoreographyTask task : chorTasks) {
			if (task.getParticipantRef().getName().compareTo(partId) == 0) {
				if (isExtern(task.getInitialParticipant())) {
					addresses.add(task.getInitialParticipant().getName());
				}
			}
		}
		addressesWithoutDuplicates = new ArrayList<>(new HashSet<>(addresses));
		for (String addr : addressesWithoutDuplicates) {
			result_addresses += "    address " + addr + ";\n";
		}

		result_addresses += "\n    constructor(";

		Iterator<String> iterator = addressesWithoutDuplicates.iterator();
		while (iterator.hasNext()) {
			result_addresses += "address _" + iterator.next();
			if (iterator.hasNext())
				result_addresses += ", ";
		}

		result_addresses += ") {\n";

		for (String addr : addressesWithoutDuplicates) {
			result_addresses += "        " + addr + " = _" + addr + ";\n";
		}

		result_addresses += "    }\n";

		return result_addresses;
	}

	private void getChoreographyTasks() {
		for (SequenceFlow flow : modelInstance.getModelElementsByType(SequenceFlow.class)) {
			// node to be processed, created by the target reference of the sequence flow
			ModelElementInstance node = modelInstance.getModelElementById(flow.getAttributeValue("targetRef"));

			if (node instanceof ModelElementInstanceImpl && !(node instanceof EndEvent)
					&& !(node instanceof ParallelGateway) && !(node instanceof ExclusiveGateway)
					&& !(node instanceof EventBasedGateway)) {
				chorTasks.add(new ChoreographyTask((ModelElementInstanceImpl) node, modelInstance));
			}
		}
	}

	private boolean isExtern(Participant participant) {
		return participant.getName().contains("EXT_");
	}

	public void flowNodeSearch() {
		for (SequenceFlow flow : modelInstance.getModelElementsByType(SequenceFlow.class)) {
			ModelElementInstance node = modelInstance.getModelElementById(flow.getAttributeValue("targetRef"));
			ModelElementInstance start = modelInstance.getModelElementById(flow.getAttributeValue("sourceRef"));
			/*
			 * if(start instanceof ReceiveTask) {
			 * 
			 * }
			 */
		}
	}

	private String getTaskFunctions(String partId) {
		String functions = "\n";
		for (ChoreographyTask task : chorTasks) {
			if (task.getInitialParticipant().getName().compareTo(partId) == 0
					|| task.getParticipantRef().getName().compareTo(partId) == 0) {
				if (task.getInitialParticipant().getName().compareTo(partId) == 0) {
					// create function that sets variables and calls other contract method
					Collection<Variable> variables = getVariables(task.getRequest().getMessage());

					String funName = task.getRequest().getMessage().getName().split("\\(")[0];
					functions += "    function " + funName + " () public {\n";

					String participant = getParticipant(task.getRequest().getTarget().getId()).getName();
					String participantReference = participant.substring(0, 1).toLowerCase() + participant.substring(1);
					functions += "        " + participantReference + "." + funName + "(";
					for (Variable v : variables)
						functions += v.getValue() + ", ";
					functions = functions.substring(0, functions.length() - 2); // remove ", "
					functions += ");\n";
				} else { // is receiving
					Collection<Variable> variables = getVariables(task.getRequest().getMessage());

					functions += "    function " + task.getRequest().getMessage().getName().split("\\(")[0] + " (";
					Iterator<Variable> iter = variables.iterator();
					while (iter.hasNext()) {
						Variable v = iter.next();
						functions += v.getType() + " _" + v.getName();
						if (iter.hasNext())
							functions += ", ";
					}
					functions += ") public {\n";

					for (Variable v : variables) {
						functions += "        " + v.getName() + " = _" + v.getName() + ";\n";
						functions += "        emit " + v.getName() + "Changed" + " (" + v.getName() + ");\n";
					}

					if (isExtern(task.getInitialParticipant())) { // setter message from extern

						// TODO
					} else { // message from other function
						functions += "    }\n\n";
						continue;
						// TODO
					}
				}

				// call the next sequence node
				ModelElementInstance modelElement = modelInstance.getModelElementById(
						task.getOutgoing().stream().findAny().orElseThrow().getAttributeValue("targetRef"));
				// assumes that there's one single outgoing
				boolean done = false;
				do {
					if (isGateway(modelElement)) {
						if (isGatewayOpen((Gateway) modelElement)) {
							Gateway gw = (Gateway) modelElement;
							// notify all the other components and this one
							functions += "        opening_" + gw.getId() + "();\n";
							for (String p : participantsWithoutDuplicates) {
								if (partId.compareTo(p) != 0)
									functions += "        " + p.substring(0, 1).toLowerCase() + p.substring(1)
											+ ".opening_" + gw.getId() + "();\n";
							}

							done = true;
						} else {
							// skip and update outgoing. Assumes that closing gateways have a single
							// outgoing
							modelElement = modelInstance.getModelElementById(((Gateway) modelElement).getOutgoing()
									.stream().findAny().orElseThrow().getAttributeValue("targetRef"));
						}
					} else if (isChoreographyTask(modelElement)) {
						ChoreographyTask ct = new ChoreographyTask((ModelElementInstanceImpl) modelElement,
								modelInstance);
						String f = ct.getRequest().getMessage().getName().split("\\(")[0];
						if (isExtern(ct.getInitialParticipant())) {
							// enable receiving message from extern
							String p = ct.getParticipantRef().getName();
							functions += "        " + p.substring(0, 1).toLowerCase() + p.substring(1) + ".enable_" + f
									+ "();\n";
						} else {
							// call the function associated with the task
							String p = ct.getInitialParticipant().getName();
							if (!p.equals(partId))
								functions += "        " + p.substring(0, 1).toLowerCase() + p.substring(1) + ".";
							functions += "        " + f + "();\n";
						}

						done = true;
					} else if (modelElement instanceof EndEvent) {
						// notifies all of ending
						functions += "        end();\n";
						for (String p : participantsWithoutDuplicates) {
							if (partId.compareTo(p) != 0)
								functions += "        " + p.substring(0, 1).toLowerCase() + p.substring(1) + "end();\n";
						}

						done = true;
					}

					// assumes that there are no other possibilities
				} while (!done);

				functions += "    }\n\n";
			}
		}

		// TODO for every gateway take an action at opening
		return functions;
	}

	private String getGatewayFunctions(String partId) {
		String functions="\n";
		
		for(Gateway gw : gateways) {
			if(isGatewayOpen(gw)) {
				functions+="    function opening_"+gw.getId()+"() {\n";
				if(gw instanceof ExclusiveGateway) {
					
					//gw.getOutgoing().stream().filter(sf->sf.getName());
					//TODO controllare che nei nomi dei SequenceFlow uscenti, la variabile appartenga a questo contratto e in tal caso fare la condizione con gli if tipo quella che sta nell'esempio
				}else if(gw instanceof ParallelGateway) {
					//TODO controllare se tra i nodi uscenti c'è un task che riguarda il proprio contratto. Chiamarlo se il mittente è partId altrimenti se il mittente è ext e il ricevente è partId, abilitarlo
					//gw.getOutgoing().stream()
					
				}else if(gw instanceof EventBasedGateway) {
					//TODO non per adesso
				}
			}
		}
		
		functions+="    }\n\n";
		
		// TODO
		return functions;
	}

	private boolean isChoreographyTask(ModelElementInstance modelElement) {
		if (modelElement instanceof ModelElementInstanceImpl && !(modelElement instanceof EndEvent)
				&& !(modelElement instanceof ParallelGateway) && !(modelElement instanceof ExclusiveGateway)
				&& !(modelElement instanceof EventBasedGateway))
			return true;
		else
			return false;
	}

	private boolean isGateway(ModelElementInstance modelElement) {
		if ((modelElement instanceof ParallelGateway) || (modelElement instanceof ExclusiveGateway)
				|| (modelElement instanceof EventBasedGateway))
			return true;
		else
			return false;
	}

	private boolean isGatewayOpen(Gateway gateway) {
		if (gateway.getIncoming().size() == 1 && gateway.getOutgoing().size() > 1)
			return true;
		else if (gateway.getIncoming().size() > 1 && gateway.getOutgoing().size() == 1)
			return false;
		System.out.println(gateway.getId() + " incoming: " + gateway.getIncoming().size() + " - outgoing: "
				+ gateway.getOutgoing().size());
		throw new IllegalArgumentException();
	}
}
