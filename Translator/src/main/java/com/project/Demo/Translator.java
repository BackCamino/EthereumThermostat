package com.project.Demo;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;

import org.camunda.bpm.model.bpmn.Bpmn;
import org.camunda.bpm.model.bpmn.BpmnModelInstance;
import org.camunda.bpm.model.bpmn.instance.EndEvent;
import org.camunda.bpm.model.bpmn.instance.EventBasedGateway;
import org.camunda.bpm.model.bpmn.instance.ExclusiveGateway;
import org.camunda.bpm.model.bpmn.instance.FlowNode;
import org.camunda.bpm.model.bpmn.instance.Message;
import org.camunda.bpm.model.bpmn.instance.MessageFlow;
import org.camunda.bpm.model.bpmn.instance.ParallelGateway;
import org.camunda.bpm.model.bpmn.instance.Participant;
import org.camunda.bpm.model.bpmn.instance.SequenceFlow;
import org.camunda.bpm.model.xml.impl.instance.ModelElementInstanceImpl;
import org.camunda.bpm.model.xml.instance.ModelElementInstance;

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
	private String solidityFile;

	public static void main(String[] args) {
		Translator translator = new Translator();
		File bpnmFile = new File("./model.bpmn");
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
		translator.getParticipants();
		translator.getMessages();
		translator.getChoreographyTasks();
		solidityFile = translator.init();
		System.out.println(solidityFile);
		// translator.writeFile();
	}

	private String init() {
		String intro = "pragma solidity ^0.6.9;\n" + "pragma experimental ABIEncoderV2;\n";
		for (String participant : participantsWithoutDuplicates) {
			intro += "\ncontract " + participant + " {" + getContractParams(participant) + getAddresses(participant)
					+ getEvents(participant) + getFunctions(participant) + "}";
		}
		return intro;
	}

	public void readFile(File bpFile) throws IOException {
		modelInstance = Bpmn.readModelFromFile(bpFile);
		allNodes = modelInstance.getModelElementsByType(FlowNode.class);
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

	private String getContractParams(String contractName) {
		String params = "\n";
		for (MessageFlow mFlow : messageFlows) {
			if (contractName.compareTo(getParticipant(mFlow.getTarget().getId()).getName()) == 0) {
				Collection<Variable> variables = getVariables(mFlow.getMessage());

				// define attributes
				for (Variable v : variables) {
					params += "    " + v.getType() + " " + v.getName() + ";\n";
				}
			}
		}
		return params;
	}

	private String getEvents(String contractName) {
		String events = "\n";
		for (MessageFlow mFlow : messageFlows) {
			if (contractName.compareTo(getParticipant(mFlow.getTarget().getId()).getName()) == 0) {
				Collection<Variable> variables = getVariables(mFlow.getMessage());

				// define events for changing attributes
				for (Variable v : variables) {
					events += "    event " + v.getName() + "Change (" + v.getType() + " _" + v.getName() + ");\n";
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

	private String getFunctions(String partId) {
		String functions = "\n";
		for (MessageFlow msgFlow : messageFlows) {
			if (partId.compareTo(getParticipant(msgFlow.getTarget().getId()).getName()) == 0) {
				Collection<Variable> variables = getVariables(msgFlow.getMessage());

				functions += "    function (";
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

	private Collection<Variable> getVariables(Message msg) {
		HashSet<Variable> res = new HashSet<>();
		for (String var : msg.getName().split("\\(")[1].replace(")", "").trim().split("\\,")) {
			String[] varParts = var.trim().split(" ");
			res.add(new Variable(varParts[0], varParts[1]));
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

		for (String addr : addressesWithoutDuplicates) {
			result_addresses += "address _" + addr + ", ";
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
}
