package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;

import java.util.List;

public class OwnedContract extends Contract {
    private static final String DEFAULT_CONTRACT_NAME = "Owned";

    public OwnedContract(String name) {
        super(name);

        //attributes
        this.addAttribute(ownerAttribute());

        //constructor
        Constructor constructor = new Constructor(name,
                Visibility.PUBLIC,
                List.of(),
                List.of(ownerAttribute().assignment(new Value("msg.sender")))
        );
        this.setConstructor(constructor);

        //modifiers
        this.addModifier(onlyAddressModifier());
        this.addModifier(onlyOwnerModifier());

        //TODO transfer ownership function
        //TODO getOwner function or make owner attribute public
        //TODO addressValidator modifier (optional)
    }

    public static Modifier onlyOwnerModifier() {
        return new Modifier(
                "onlyOwner",
                Visibility.PUBLIC,
                List.of(),
                List.of(
                        new Statement("require(msg.sender == " + ownerAttribute().getName() + ", \"Address not valid\");"),
                        new Modifier.SpecialUnderscore()
                ),
                false
        );
    }

    public static Modifier onlyAddressModifier() {
        Variable addressParameter = new Variable("_address", new Type(Type.BaseTypes.ADDRESS), Visibility.PRIVATE);
        return new Modifier(
                "onlyAddress",
                Visibility.PUBLIC,
                List.of(addressParameter),
                List.of(
                        new Statement("require(_address != address(0), \"Address not valid\");"),
                        new Modifier.SpecialUnderscore()
                ),
                false
        );
    }

    public static Variable ownerAttribute() {
        return new Variable("owner", new Type(Type.BaseTypes.ADDRESS), Visibility.PRIVATE);
    }

    public OwnedContract() {
        this(DEFAULT_CONTRACT_NAME);
    }
}
