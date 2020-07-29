package com.github.BackCamino.EthereumThermostat.bpmn2sol.bpmnelements;

import org.camunda.bpm.model.bpmn.BpmnModelInstance;
import org.camunda.bpm.model.bpmn.instance.*;
import org.camunda.bpm.model.xml.impl.instance.ModelElementInstanceImpl;
import org.camunda.bpm.model.xml.instance.DomElement;
import org.camunda.bpm.model.xml.instance.ModelElementInstance;

import java.util.ArrayList;

public class ChoreographyTask {
    ModelElementInstanceImpl task;
    ArrayList<SequenceFlow> incoming, outgoing;
    Participant participantRef = null;
    MessageFlow request = null, response = null;
    Participant initialParticipant;
    String id, name;
    BpmnModelInstance model;
    TaskType type;

    public enum TaskType {
        ONEWAY, TWOWAY
    }

    public ChoreographyTask(ModelElementInstanceImpl task, BpmnModelInstance modelInstance) {
        this.model = modelInstance;
        this.task = task;
        this.incoming = new ArrayList<SequenceFlow>();
        this.outgoing = new ArrayList<SequenceFlow>();
        this.initialParticipant = model.getModelElementById(task.getAttributeValue("initiatingParticipantRef"));
        this.id = task.getAttributeValue("id");
        this.name = task.getAttributeValue("name");
        init();
    }

    private void init() {
        for (DomElement childElement : task.getDomElement().getChildElements()) {
            String type = childElement.getLocalName();
            switch (type) {
                case "incoming":
                    incoming.add((SequenceFlow) model.getModelElementById(childElement.getTextContent()));
                    break;
                case "outgoing":
                    outgoing.add((SequenceFlow) model.getModelElementById(childElement.getTextContent()));
                    break;
                case "participantRef":
                    Participant p = model.getModelElementById(childElement.getTextContent());
                    if (!p.equals(initialParticipant)) {
                        participantRef = p;
                    }
                    break;
                case "messageFlowRef":
                    //System.out.println(task.getAttributeValue("id"));
                    MessageFlow m = model.getModelElementById(childElement.getTextContent());
                    //System.out.println("CHILD TEXT CONTENT: " + childElement.getTextContent());

                    //System.out.println("MESSAGE FLOW è: " + m.getId() + "con nome: " + m.getName() + "con messaggio: " + m.getMessage().getId());
                    if (m.getSource().getId().equals(initialParticipant.getId())) {
                        request = m;
                    } else {
                        response = m;
                    }

                    break;
                case "extensionElements":
                    break;
                default:
                    throw new IllegalArgumentException("Invalid element in the xml: " + type);

            }
        }

        if (response != null) {
            type = TaskType.TWOWAY;
        } else {
            type = TaskType.ONEWAY;
        }
    }

    public ModelElementInstance getTask() {
        return task;
    }

    public void setTask(ModelElementInstanceImpl task) {
        this.task = task;
    }

    public ArrayList<SequenceFlow> getIncoming() {
        return incoming;
    }

    public void setIncoming(ArrayList<SequenceFlow> incoming) {
        this.incoming = incoming;
    }

    public ArrayList<SequenceFlow> getOutgoing() {
        return outgoing;
    }

    public void setOutgoing(ArrayList<SequenceFlow> outgoing) {
        this.outgoing = outgoing;
    }

    public Participant getParticipantRef() {
        return participantRef;
    }

    public void setParticipantRef(Participant participantRef) {
        this.participantRef = participantRef;
    }

    public MessageFlow getRequest() {
        return request;
    }

    public void setRequest(MessageFlow request) {
        this.request = request;
    }

    public MessageFlow getResponse() {
        return response;
    }

    public void setResponse(MessageFlow response) {
        this.response = response;
    }

    public Participant getInitialParticipant() {
        return initialParticipant;
    }

    public void setInitialParticipant(Participant initialParticipant) {
        this.initialParticipant = initialParticipant;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BpmnModelInstance getModel() {
        return model;
    }

    public void setModel(BpmnModelInstance model) {
        this.model = model;
    }

    public TaskType getType() {
        return type;
    }

    public void setType(TaskType type) {
        this.type = type;
    }

    public static boolean isChoreographyTask(ModelElementInstance modelElement) {
        if (modelElement instanceof ModelElementInstanceImpl
                && !(modelElement instanceof EndEvent)
                && !(modelElement instanceof StartEvent)
                && !(modelElement instanceof Gateway)
                && !(modelElement instanceof Task))
            return true;
        return false;
    }
}
