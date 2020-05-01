pragma solidity ^0.6.1;

import "./Sensor.sol";
import "./Heater.sol";
import "./Status.sol";


/*
Contratti multipli
*/

contract Thermostat {
    Heater private heater;
    Sensor private sensor;
    Status private status;
    int16 private threshold;
    address private owner;

    /// an initial threshold must be provided
    constructor(int16 _threshold) public {
        owner = msg.sender;
        setStatus(Status.OFF);
        threshold = _threshold;
    }

    modifier mustBeOn() {
        require(status == Status.ON, "Thermostat must be ON");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Thermostat owner allowed");
        _;
    }

    modifier onlySensor() {
        require(msg.sender == address(sensor), "Only Sensor allowed");
        _;
    }

    modifier onlyHeater() {
        require(msg.sender == address(heater), "Only Heater allowed");
        _;
    }

    event ThermostatStatusChanged(Status _status);

    event HeaterStatusChanged(Status _status);

    event TempChanged(int16 _temp);

    function setSensor(address sensorAddress) public onlyOwner {
        require(sensorAddress != address(0), "Address not valid");
        sensor = Sensor(sensorAddress);
    }

    function setHeater(address heaterAddress) public onlyOwner {
        require(heaterAddress != address(0), "Address not valid");
        heater = Heater(heaterAddress);
    }

    function heaterStatusChanged(Status _status) external mustBeOn {
        emit HeaterStatusChanged(_status);
    }

    /// set the thermostat ON or OFF
    function setStatus(Status _status) public onlyOwner {
        if (status != _status) emit ThermostatStatusChanged(_status);
        status = _status;
    }

    function getStatus() public view returns (Status) {
        return status;
    }

    function getTemp() public view mustBeOn returns (int16) {
        return sensor.getTemp();
    }

    /// notifies the thermostat that the temperature has changed
    function tempChanged(int16 _temp) public mustBeOn onlySensor {
        update(_temp, threshold);
        emit TempChanged(_temp);
    }

    /// sets a new threshold temperature
    function setThreshold(int16 _threshold) public mustBeOn onlyOwner {
        threshold = _threshold;
        update(sensor.getTemp(), threshold);
    }

    function getThreshold() public view mustBeOn returns (int16) {
        return threshold;
    }

    function update(int16 _temp, int16 _threshold) private mustBeOn {
        if (_threshold > _temp) heater.setOn();
        else heater.setOff();
    }
}
