pragma solidity ^0.6.1;

import "./Thermostat.sol";


contract Sensor {
    address private owner;
    Thermostat private thermostat;
    int16 private temp;

    /// an initial temp must be provided
    constructor(int16 _temp) public {
        owner = msg.sender;
        temp = _temp;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    event TempChanged(int16 _temp);

    function getTemp() public view returns (int16) {
        return temp;
    }

    function setTemp(int16 _temp) public onlyOwner {
        temp = _temp;
        emit TempChanged(temp);
        if (address(thermostat) != address(0)) thermostat.tempChanged(temp);
    }

    function setThermostat(address thermostatAddress) public onlyOwner {
        require(thermostatAddress != address(0), "Address not valid");
        thermostat = Thermostat(thermostatAddress);
    }
}
