package com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.helpers;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Comment;
import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.Contract;
import org.camunda.bpm.model.bpmn.instance.Participant;

import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.function.Predicate;

public class ContractsSet implements Set<Contract> {
    private Set<Contract> contracts = new LinkedHashSet<>();

    public Contract getContract(Participant participant) {
        return this.getContract(el -> el.getName().equals(participant.getName()));
    }

    public Contract getContract(String name) {
        return this.getContract(el -> el.getName().equals(name));
    }

    public Contract getContract(Predicate<? super Contract> predicate) {
        return this.contracts
                .parallelStream()
                .filter(predicate)
                .findAny()
                .orElseThrow();
    }

    public boolean add(Participant participant) {
        Contract contract = new Contract(participant.getName());
        contract.setComment(new Comment("Contract representation of the participant " + participant.getName() + " " + participant.getId() + ".\nMultiplicity (max): " +
                (participant.getParticipantMultiplicity() == null ? 1 : participant.getParticipantMultiplicity().getMaximum()) +
                ".", true));
        return this.contracts.add(contract);
    }

    public boolean add(String name) {
        return this.contracts.add(new Contract(name));
    }

    @Override
    public int size() {
        return this.contracts.size();
    }

    @Override
    public boolean isEmpty() {
        return this.contracts.isEmpty();
    }

    @Override
    public boolean contains(Object o) {
        return this.contracts.contains(o);
    }

    @Override
    public Iterator<Contract> iterator() {
        return this.contracts.iterator();
    }

    @Override
    public Object[] toArray() {
        return this.contracts.toArray();
    }

    @Override
    public <T> T[] toArray(T[] a) {
        return this.contracts.toArray(a);
    }

    @Override
    public boolean add(Contract contract) {
        return this.contracts.add(contract);
    }

    @Override
    public boolean remove(Object o) {
        return this.contracts.remove(o);
    }

    @Override
    public boolean containsAll(Collection<?> c) {
        return this.contracts.containsAll(c);
    }

    @Override
    public boolean addAll(Collection<? extends Contract> c) {
        return this.contracts.addAll(c);
    }

    @Override
    public boolean retainAll(Collection<?> c) {
        return this.contracts.retainAll(c);
    }

    @Override
    public boolean removeAll(Collection<?> c) {
        return this.contracts.removeAll(c);
    }

    @Override
    public void clear() {
        this.contracts.clear();
    }
}
