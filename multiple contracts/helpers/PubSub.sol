pragma solidity ^0.6.1;


interface Subscriber {
    function accept(string calldata _event, bytes32 value) external;
}


abstract contract Publisher {
    Subscriber[] private subscribers;

    event Pubblication(string _event, bytes32 _value);

    function subscribeAddress(address _address) public {
        require(_address != address(0), "Address not valid");
        subscribe(Subscriber(_address));
    }

    function subscribe(Subscriber _subscriber) public {
        subscribers.push(_subscriber);
    }

    function publish(string memory _event, bytes32 _value) internal {
        emit Pubblication(_event, _value);

        for (uint256 i = 0; i < subscribers.length; i++)
            subscribers[i].accept(_event, _value);
    }

    //TODO function to remove subscriber

    //TODO modifier only subscriber
}
