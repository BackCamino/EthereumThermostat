pragma solidity ^0.6.1;


enum Status {OFF, ON, ERR}

abstract contract Switchable {
    Status private status;

    constructor(Status _status) public {
        status = _status;
        emit StatusChanged(status);
    }

    modifier statusMustBe(Status _status) {
        require(status == _status, "Invalid current status");
        _;
    }

    modifier statusOrNothing(Status _status) {
        if (status != _status) return;
        _;
    }

    modifier notError() {
        require(status != Status.ERR, "Problems on the device");
        _;
    }

    event StatusChanged(Status _status);

    function setStatus(Status _status) public virtual {
        //TODO emit event only if status changed
        status = _status;
        emit StatusChanged(status);
    }

    function getStatus() public view returns(Status _status){
        return status;
    }
}
