pragma solidity^0.6.1;

import "./Status.sol";

contract Heater{
    Status status;
    address owner;

    constructor()public{
        status=Status.OFF;
        owner=msg.sender;
    }

    modifier onlyHeater(){
        require(owner==msg.sender,"Only sensor can call this function");
        _;
    }
    
    function setON() public onlyHeater{
        status=Status.ON;
    }

    function setOFF() public onlyHeater{
        status=Status.OFF;
    }
    
    function getStatus() public view onlyHeater returns(Status){
        return status;
    }
    
}