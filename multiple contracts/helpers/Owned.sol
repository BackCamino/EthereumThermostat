pragma solidity ^0.6.1;


abstract contract Owned {
    address private owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyAddress(address _address) {
        require(msg.sender == _address, "Caller not allowed");
        _;
    }

    modifier addressValidator(address _address) {
        require(_address != address(0), "Address not valid");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }

    function transferOwnership(address _owner) public onlyOwner {
        owner = _owner;
    }

    function getOwner() public view returns (address _owner) {
        return owner;
    }
}
