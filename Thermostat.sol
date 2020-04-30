pragma solidity ^0.6.1;

import "./Sensor.sol";
import "./Heater.sol";
import "./Status.sol";


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

    modifier onlyOn() {
        require(status == Status.ON, "the devise must be on");
        _;
    }

    modifier onlySensor() {
        require(msg.sender == address(sensor), "Only Sensor allowed");
        _;
    }

    modifier onlyThermostat() {
        require(msg.sender == owner, "Only Thermostat can do this function");
        _;
    }

    modifier onlyHeater() {
        require(
            msg.sender == address(heater),
            "Only Heater can do this function"
        );
        _;
    }

    event ThermostatStatusChanged(Status _status);

    event HeaterStatusChanged(Status _status);

    event TempChanged(int16 _temp);

    function setSensor(address sensorAddress) public onlyThermostat {
        require(sensorAddress != address(0), "Address not valid");
        sensor = Sensor(sensorAddress);
    }

    function setHeater(address heaterAddress) public onlyThermostat {
        require(heaterAddress != address(0), "Address not valid");
        heater = Heater(heaterAddress);
    }

    function heaterStatusChanged(Status _status) external onlyOn {
        emit HeaterStatusChanged(_status);
    }

    function setStatus(Status _status) public onlyThermostat {
        if (status != _status) emit ThermostatStatusChanged(_status);
        status = _status;
    }

    function getStatus() public view returns (Status) {
        return status;
    }

    function getTemp() public view onlyOn returns (int16) {
        return sensor.getTemp();
    }

    /// notifies the thermostat that the temperature has changed
    function tempChanged(int16 _temp) public onlyOn {
        update(_temp, threshold);
    }

    function setThreshold(int16 _threshold) public {
        threshold = _threshold;
        update(sensor.getTemp(), threshold);
    }

    function update(int16 _temp, int16 _threshold) private {
        if (_threshold > _temp) heater.setOn();
        else heater.setOff();
        emit TempChanged(_temp);
    }

    function getThreshold() public view returns (int16) {
        return threshold;
    }
}
