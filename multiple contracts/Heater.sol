pragma solidity ^0.6.1;

import "./Status.sol";
import "./Thermostat.sol";


contract Heater {
    Thermostat private thermostat;
    Status private status = Status.OFF;
    address private owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier notError() {
        require(status != Status.ERR, "Problems on the Heater");
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner allowed");
        _;
    }

    event StatusChanged(Status _status);

    event RequestStatusChange(Status _status);

    /// the heater (gateway) sets his actual status
    function setStatus(Status _status) public onlyOwner {
        status = _status;
        emit StatusChanged(status);
        if (address(thermostat) != address(0))
            thermostat.heaterStatusChanged(status);
    }

    /// asks the heater to go on
    function setOn() external {
        emit RequestStatusChange(Status.ON);
    }

    /// asks the heater to go off
    function setOff() external {
        emit RequestStatusChange(Status.OFF);
    }

    function getStatus() public view onlyOwner returns (Status) {
        return status;
    }

    function setThermostat(address thermostatAddress) public onlyOwner {
        require(thermostatAddress != address(0), "Address not valid");
        thermostat = Thermostat(thermostatAddress);
    }
}
