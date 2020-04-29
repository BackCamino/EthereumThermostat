pragma solidity^0.6.1;

import './Sensor.sol';
import './Heater.sol';


contract Thermostat{
    Heater private heater;
    Sensor private sensor;
    address owner;
    constructor() public{
        owner=msg.sender;
    }
    
    modifier onlySensor(){
        require(msg.sender==address(sensor),"Only Sensor can do this function");
        _;
    }

    modifier onlyThermostat(){
        require(msg.sender==owner,"Only Thermostat can do this function");
        _;
    }

    modifier onlyHeater(){
        require(msg.sender==address(heater),"Only Heater can do this function");
        _;
    }

    function setSensor(address sensorAddress) public onlyThermostat {
        sensor=Sensor(sensorAddress);
    }

    function getSensorTem() public view returns(int16){
        return sensor.getTemperature();
    }
}
