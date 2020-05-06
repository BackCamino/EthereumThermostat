pragma solidity ^0.6.1;


interface Subscriber {
    function accept(string calldata _event, bytes32 value) external;
}


abstract contract Publisher {
    Subscriber[] subscribers;

    function subscribeAddress(address _address) public {
        require(_address != address(0), "Address not valid");
        subscribe(Subscriber(_address));
    }

    function subscribe(Subscriber _subscriber) public {
        subscribers.push(_subscriber);
    }

    function publish(string memory _event, bytes32 _value) internal {
        for (uint256 i = 0; i < subscribers.length; i++)
            subscribers[i].accept(_event, _value);
    }

    //TODO function to remove subscriber

    //TODO encode string event name

    //TODO emit event on publish
}
