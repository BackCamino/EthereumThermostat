package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;

import java.util.List;

public class OwnedContract extends Contract {
    private static final String DEFAULT_CONTRACT_NAME = "Owned";

    public OwnedContract(String name) {
        super(name);

        //attributes
        Variable ownerAttribute = new Variable("owner", new Type(Type.BaseTypes.ADDRESS), Visibility.PRIVATE);
        this.addAttribute(ownerAttribute);

        //constructor
        Constructor constructor = new Constructor(name,
                Visibility.PUBLIC,
                List.of(),
                List.of(new Statement(ownerAttribute.assignment(new Value("msg.sender"))))
        );
        this.setConstructor(constructor);

        //modifiers
        //only address modifier
        Variable addressParameter = new Variable("_address", new Type(Type.BaseTypes.ADDRESS), Visibility.PRIVATE);
        Modifier onlyAddressModifier = new Modifier(
                "onlyAddress",
                Visibility.PUBLIC,
                List.of(addressParameter),
                List.of(
                        new Statement("require(_address != address(0), \"Address not valid\");"),
                        new Modifier.SpecialUnderscore()
                ),
                false
        );
        this.addModifier(onlyAddressModifier);

        //only owner modifier
        Modifier onlyOwnerModifier = new Modifier(
                "onlyOwner",
                Visibility.PUBLIC,
                List.of(),
                List.of(
                        new Statement("require(msg.sender == " + ownerAttribute.getName() + ", \"Address not valid\");"),
                        new Modifier.SpecialUnderscore()
                ),
                false
        );
        this.addModifier(onlyOwnerModifier);

        //TODO transfer ownership function
        //TODO getOwner function or make owner attribute public
        //TODO addressValidator modifier (optional)
    }

    public OwnedContract() {
        this(DEFAULT_CONTRACT_NAME);
    }
}
