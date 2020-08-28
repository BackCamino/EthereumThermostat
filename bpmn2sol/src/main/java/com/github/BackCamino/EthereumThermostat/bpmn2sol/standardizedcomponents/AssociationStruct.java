package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.EmmanueleBollino.solcraft.soliditycomponents.Comment;
import com.github.EmmanueleBollino.solcraft.soliditycomponents.Struct;
import com.github.EmmanueleBollino.solcraft.soliditycomponents.Type;
import com.github.EmmanueleBollino.solcraft.soliditycomponents.Variable;
import org.camunda.bpm.model.bpmn.instance.Participant;

import java.util.LinkedList;
import java.util.List;

import static com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.StringHelper.decapitalize;

public class AssociationStruct extends Struct {
    private List<Participant> participants = new LinkedList<>();

    public AssociationStruct() {
        super("Association");
    }

    public AssociationStruct(List<Participant> participants) {
        super("Association");
        participants.forEach(this::addParticipant);
    }

    public void addParticipant(Participant participant) {
        if (!participants.contains(participant)) participants.add(participant);
        Variable field = new Variable(decapitalize(participant.getName() + "Index"), new Type(BaseTypes.UINT));
        field.setComment(new Comment("index of the participant " + participant.getName() + " in the association"));
        this.addField(field);
    }

    public List<Participant> getParticipants() {
        return this.participants;
    }
}
