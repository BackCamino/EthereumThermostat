package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Struct;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Type;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Variable;
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
        this.addField(field);
    }

    public List<Participant> getParticipants() {
        return this.participants;
    }
}
