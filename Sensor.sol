pragma solidity^0.6.1;

import './Thermostat.sol';

contract Sensor{
    address owner;
    int16 temp;
  
    constructor (int16 initialTemp)public{  
        owner=msg.sender;
        temp=initialTemp;
       
    }
    
    modifier onlyOwner{
        require(msg.sender==owner,"Only Sensor can call this function");
        _;
    }
    
    
    function getTemperature() public view returns (int16){
        return temp;
    }
    
    
    function setTemperaure(int16 temperature) public onlyOwner{
        temp= temperature;
    }
    
}