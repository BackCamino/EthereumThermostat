pragma solidity ^0.6.1;


/// A contract with a owner. The owner is the sender of the transaction to deploy the contract
abstract contract Owned {
    address private owner;

    constructor() public {
        owner = msg.sender;
    }

    /// Checks if the caller is the provided address
    modifier onlyAddress(address _address) {
        require(msg.sender == _address, "Caller not allowed");
        _;
    }

    /// Checks if the provided address is not empty
    modifier addressValidator(address _address) {
        require(_address != address(0), "Address not valid");
        _;
    }

    /// Checks if the caller is the owner
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }

    /// Sets the owner to the new address provided
    function transferOwnership(address _owner)
        public
        onlyOwner
        addressValidator(_owner)
    {
        owner = _owner;
    }

    /// Returs the address of the owner
    function getOwner() public view returns (address _owner) {
        return owner;
    }
}
