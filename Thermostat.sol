pragma solidity^0.6.1;

import './Sensor.sol';
import './Heater.sol';
import './Status.sol';

contract Thermostat{

    Heater private heater;
    Sensor private sensor;
    Status status;
    address owner;
    
    constructor() public{
        status=Status.OFF;
        owner=msg.sender;
    }
    
    modifier isOn(){
        require(status==Status.ON,"the devise must be on");
        _;
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
        
    }

    function setHeater(address sensorAddress) public onlyThermostat{
        
    }

    function setON() public{
        status=Status.ON;
    }

    function getSensorTem() public view returns(int16){
        //Non funziona 
        return sensor.getTemperature();
    }
}
