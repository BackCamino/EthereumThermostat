pragma solidity ^0.6.1;

import "./Sensor.sol";
import "./Heater.sol";
import "../helpers/Owned.sol";
import "../helpers/PubSub.sol";
import "../helpers/Switchable.sol";
import {StringUtils} from "../helpers/StringUtils.sol";


contract Thermostat is Subscriber, Owned, Switchable(Status.OFF) {
    Heater private heater;
    Sensor private sensor;
    int16 private threshold;

    /// an initial threshold must be provided
    constructor(int16 _threshold) public {
        threshold = _threshold;
    }

    function setSensor(address sensorAddress) public onlyOwner {
        require(sensorAddress != address(0), "Address not valid");
        sensor = Sensor(sensorAddress);
    }

    function setHeater(address heaterAddress) public onlyOwner {
        require(heaterAddress != address(0), "Address not valid");
        heater = Heater(heaterAddress);
    }

    function heaterStatusChanged(Status _status)
        private
        statusOrNothing(Status.ON)
    {
        //TODO
        //emit HeaterStatusChanged(_status);
    }

    function getTemp() public view statusMustBe(Status.ON) returns (int16) {
        return sensor.getTemp();
    }

    /// notifies the thermostat that the temperature has changed
    function tempChanged(int16 _temp)
        public
        statusOrNothing(Status.ON)
        onlyAddress(address(sensor))
    {
        update(_temp, threshold);
        //emit TempChanged(_temp);
    }

    /// sets a new threshold temperature
    function setThreshold(int16 _threshold)
        public
        statusMustBe(Status.ON)
        onlyOwner
    {
        threshold = _threshold;
        update(sensor.getTemp(), threshold);
    }

    function getThreshold()
        public
        view
        statusMustBe(Status.ON)
        returns (int16)
    {
        return threshold;
    }

    function update(int16 _temp, int16 _threshold)
        private
        statusMustBe(Status.ON)
    {
        if (_threshold > _temp) heater.setOn();
        else heater.setOff();
    }

    function accept(string memory _event, bytes32 value) public override {
        if (StringUtils.compareStrings(_event, "tempChanged"))
            tempChanged(int16(int256(value)));
        else if (StringUtils.compareStrings(_event, "heaterStatusChanged"))
            heaterStatusChanged(Status(uint256(value)));
    }
}
