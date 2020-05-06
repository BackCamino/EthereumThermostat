pragma solidity ^0.6.1;

import "./Thermostat.sol";
import "../helpers/Owned.sol";
import "../helpers/PubSub.sol";
import "../helpers/Switchable.sol";


contract Heater is Publisher, Owned, Switchable {
    Status private status = Status.OFF;
    address private owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier notError() {
        require(status != Status.ERR, "Problems on the Heater");
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
