pragma solidity^0.6.1;

contract Sensor{
    address sensoradderess;
    int16 temperature;


    function getTemperature() public view returns (int16){
        return temperature;
    }
    
    function setTemperaure(int16 temperatur) public{
        temperature= temperature;
    }

}