pragma solidity ^0.6.1;

import "../helpers/Owned.sol";
import "../helpers/PubSub.sol";


contract Sensor is Publisher, Owned {
    int16 private temp;

    /// an initial temp must be provided
    constructor(int16 _temp) public {
        temp = _temp;
    }

    function getTemp() public view returns (int16) {
        return temp;
    }

    function setTemp(int16 _temp) public onlyOwner {
        temp = _temp;
        publish("tempChanged", bytes32(int256(temp)));
    }

    //rimpiazzato da SubscribeAddress
    //function setThermostat(address thermostatAddress) public onlyOwner {
    //    require(thermostatAddress != address(0), "Address not valid");
    //    thermostat = Thermostat(thermostatAddress);
    // }
}
