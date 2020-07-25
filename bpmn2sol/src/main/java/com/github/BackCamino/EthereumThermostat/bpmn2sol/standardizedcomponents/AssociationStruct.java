package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Struct;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Type;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Variable;
import org.camunda.bpm.model.bpmn.instance.Participant;

import java.util.List;

import static com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers.StringHelper.decapitalize;

public class AssociationStruct extends Struct {
    public AssociationStruct() {
        super("Association");
    }

    public AssociationStruct(List<Participant> participants) {
        super("Association");
        participants.forEach(this::addParticipant);
    }

    public void addParticipant(Participant participant) {
        Variable field = new Variable(decapitalize(participant.getName() + "Index"), new Type(BaseTypes.UINT));
        this.addField(field);
    }
}
