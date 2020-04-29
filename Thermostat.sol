pragma solidity^0.6.1;

import './Sensor.sol';


contract Thermostat{
    Sensor private sensor;
    address owner;
    constructor() public{
        owner=msg.sender;
    }
    
    modifier onlySensor(){
        require(msg.sender==address(sensor),"ciao");
        _;
    }
    modifier onlyThermostat(){
        require(msg.sender==owner,"ciao");
        _;
    }
    function setSensor(address sensorAddress) public onlyThermostat {
        sensor=Sensor(sensorAddress);
    }
    function getSensorTem() public view returns(int16){
        return sensor.getTemperature();
    }
}
