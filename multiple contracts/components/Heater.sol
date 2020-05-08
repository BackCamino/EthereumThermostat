pragma solidity ^0.6.1;

import "../helpers/Owned.sol";
import "../helpers/PubSub.sol";
import "../helpers/Switchable.sol";


contract Heater is Publisher, Owned, Switchable(Status.OFF) {
    event RequestStatusChange(Status _status);

    // the heater (gateway) sets his actual status

    // TODO check who can call setOn and setOff

    // TODO setStatus onlyOwner

    /// asks the heater to go on
    function setOn() external {
        emit RequestStatusChange(Status.ON);
    }

    /// asks the heater to go off
    function setOff() external {
        emit RequestStatusChange(Status.OFF);
    }

    //TODO status only owner
}
