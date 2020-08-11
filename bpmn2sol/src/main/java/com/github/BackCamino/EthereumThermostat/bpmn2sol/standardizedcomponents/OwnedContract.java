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

        //functions
        this.addFunction(transferOwnership());
        this.addFunction(validateAddress());
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
                        new Statement("require(msg.sender == _address, \"Address not allowed\");"),
                        new Modifier.SpecialUnderscore()
                ),
                false
        );
        onlyAddressModifier.setComment(new Comment("Restricts access to the modified function only to the provided address.", true));

        return onlyAddressModifier;
    }

    public static Function transferOwnership() {
        Function transferOwnership = new Function("transferOwnership");
        transferOwnership.setVisibility(Visibility.EXTERNAL);
        transferOwnership.addParameter(new Variable("newOwner", new Type(Type.BaseTypes.ADDRESS)));
        transferOwnership.addModifier(onlyOwnerModifier());
        transferOwnership.addStatement(requireValidAddress(new Value("_newOwner")));
        transferOwnership.addStatement(new Statement("owner = _newOwner;"));
        transferOwnership.setComment(new Comment("Transfers the ownership of the contract, changes the address of the owner.", true));

        return transferOwnership;
    }

    public static Function validateAddress() {
        Function validateAddress = new Function("validateAddress");
        validateAddress.setVisibility(Visibility.INTERNAL);
        validateAddress.setMarker(Function.Markers.PURE);
        validateAddress.addParameter(new Variable("address", new Type(Type.BaseTypes.ADDRESS)));
        validateAddress.addReturned(new Variable("isValid", new Type(Type.BaseTypes.BOOL)));
        validateAddress.addStatement(new Statement("return _address != address(0);"));
        validateAddress.setComment(new Comment("Checks whether an address is valid or not.\nAn invalid address means a full zero address.", true));

        return validateAddress;
    }

    public static Require requireValidAddress(Value value) {
        return new Require(new Condition(validateAddress().invocation(value).replace(";", "")), "Address not valid");
    }

    public static Variable ownerAttribute() {
        return new Variable("owner", new Type(Type.BaseTypes.ADDRESS), Visibility.PRIVATE);
    }

    public OwnedContract() {
        this(DEFAULT_CONTRACT_NAME);
    }
}
