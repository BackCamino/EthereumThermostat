package com.github.BackCamino.EthereumThermostat.bpmn2sol.standardizedcomponents;

import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;

import java.util.List;

public class OwnedContract extends Contract {
    private static final String DEFAULT_CONTRACT_NAME = "Owned";

    public OwnedContract(String name) {
        super(name);

        this.setComment(new Comment("This abstract contract represents a contract with a owner.\nThe owner is the one who creates the contract.\nSo this contract provides modifiers and utils to manage property control.", true));

        this.setAbstract(true);

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
        Modifier onlyOwnerModifier = new Modifier(
                "onlyOwner",
                Visibility.PUBLIC,
                List.of(),
                List.of(
                        new Statement("require(msg.sender == " + ownerAttribute().getName() + ", \"Address not valid\");"),
                        new Modifier.SpecialUnderscore()
                ),
                false
        );
        onlyOwnerModifier.setComment(new Comment("Restricts access to the modified function only to the owner.", true));

        return onlyOwnerModifier;
    }

    public static Modifier onlyAddressModifier() {
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
        onlyAddressModifier.setComment(new Comment("Restricts access to the modified function only to the provided address.", true));

        return onlyAddressModifier;
    }

    public static Variable ownerAttribute() {
        return new Variable("owner", new Type(Type.BaseTypes.ADDRESS), Visibility.PRIVATE);
    }

    public OwnedContract() {
        this(DEFAULT_CONTRACT_NAME);
    }
}
