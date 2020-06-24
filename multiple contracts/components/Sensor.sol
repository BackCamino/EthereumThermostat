pragma solidity ^0.6.1;

import "../helpers/Owned.sol";
import "../helpers/PubSub.sol";

contract Sensor is Publisher, Owned {
    int16 private temp;

    event TempChanged(int16 temp);

    /// Construct a temperature sensor with an initial temp
    constructor(int16 _temp) public {
        temp = _temp;
    }

    function getTemp() public view returns (int16) {
        return temp;
    }

    function setTemp(int16 _temp) public onlyOwner {
        temp = _temp;
        emit TempChanged(temp);
        publish("tempChanged", bytes32(int256(temp)));
    }
}
