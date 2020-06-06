package com.project.Demo;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;

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
	
	private static BpmnModelInstance modelInstance;
	public static Collection<FlowNode> allNodes;
	public static ArrayList<String> participants;
	public static ArrayList<String> participantsWithoutDuplicates;
	public static Collection<Message> messages;
	public static Collection<MessageFlow> messageFlows;
	public static ArrayList<String> externParticipants;
	public static ArrayList<String> externParticipantsWithoutDuplicates;
	public static Collection<ChoreographyTask> chorTasks;
	public static String solidityFile;
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		File bpnmFile = new File("C:/Users/Diego/Documents/model.bpnm");
		try {
			run(bpnmFile);
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
	
	public static void run(File bpmnFile) throws Exception {
		Translator translator = new Translator();
		translator.readFile(bpmnFile);
		translator.getParticipants();
		translator.getMessages();
		translator.getChoreographyTasks();
		solidityFile = translator.init();
		System.out.println(solidityFile);
		//translator.writeFile();
	}
	
	private String init() {
		String intro = "pragma solidity ^0.5.3; \n" + "	pragma experimental ABIEncoderV2;\n";
		for(String participant : participantsWithoutDuplicates) {
			intro += "\ncontract " + participant + " {" 
			 + getContractParams(participant) + getAddresses(participant) + getFunctions(participant) + "}";
		}
		return intro;
	}
	
	
	public void readFile(File bpFile) throws IOException {
		modelInstance = Bpmn.readModelFromFile(bpFile);
		allNodes = modelInstance.getModelElementsByType(FlowNode.class);
	}
	
	private void writeFile() throws IOException, Exception {
		FileWriter wChor = new FileWriter(new File(/* Project patch + */ File.separator + "resources"
				+ File.separator /* + File name + .sol */));
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
		for(MessageFlow mFlow : messageFlows) {
			if(contractName.compareTo(getParticipant(mFlow.getTarget().getId()).getName()) == 0) {
				Message msg = mFlow.getMessage();
				String[] result = msg.getName().split("\\(");
				params += "    " + result[1].split("\\)")[0] + ";\n";
			}
		}
		return params;
	}
	
	
	private Participant getParticipant(String partId) {
		return modelInstance.getModelElementById(partId);
	}
	
	
	private void getParticipants() {
		Collection<Participant> parti = modelInstance.getModelElementsByType(Participant.class);
		for (Participant p : parti) {
			if(!isExtern(p)) {
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
		for(MessageFlow msgFlow : messageFlows) {
			if(partId.compareTo(getParticipant(msgFlow.getTarget().getId()).getName()) == 0) {
				functions += "    function " + msgFlow.getMessage().getName() +" public {\n";
				functions += "    }\n\n";
			}
		}
		return functions;
	}
	
	private String getAddresses(String partId) {
		String result_addresses = "\n";
		ArrayList<String> addresses = new ArrayList<String>();
		ArrayList<String> addressesWithoutDuplicates = new ArrayList<String>();
		
		for(ChoreographyTask task : chorTasks) {
			if(task.getParticipantRef().getName().compareTo(partId) == 0) {
				if(isExtern(task.getInitialParticipant())) {
					addresses.add(task.getInitialParticipant().getName());
				}
			}
		}
		addressesWithoutDuplicates = new ArrayList<>(new HashSet<>(addresses));
		for(String addr : addressesWithoutDuplicates) {
			result_addresses += "    address " + addr + ";\n";
		}
		
		result_addresses += "\n    constructor(";
		
		for(String addr : addressesWithoutDuplicates) {
			result_addresses += "address _" + addr + ", ";
		}
		
		result_addresses += ") {\n";
		
		for(String addr : addressesWithoutDuplicates) {
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
			/*if(start instanceof ReceiveTask) {
				
			}*/
		}
	}
}
