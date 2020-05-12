pragma solidity ^0.6.1;

import "../helpers/Owned.sol";
import "../helpers/PubSub.sol";
import "../helpers/Switchable.sol";


contract Heater is Publisher, Owned, Switchable(Status.OFF) {
    event RequestStatusChange(Status _status);

    // the heater (gateway) sets its actual REAL status and a caller can request a setOn or setOff

    // TODO check who can call setOn and setOff

    // TODO setStatus onlyOwner

    // TODO check who can subscribe

    /// asks the heater to go on
    function setOn() external {
        requestStatusChange(Status.ON);
    }

    /// asks the heater to go off
    function setOff() external {
        requestStatusChange(Status.OFF);
    }

    /// asks the heater to change its status
    function requestStatusChange(Status _status) public {
        //TODO check who can call (only subscribers?)
        require(
            _status == Status.ON || _status == Status.OFF,
            "Invalid request status change"
        );
        emit RequestStatusChange(_status);
    }
}
