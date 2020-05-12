pragma solidity ^0.6.1;


library StringUtils {
    function compareStrings(
        string memory firstString,
        string memory secondString
    ) public pure returns (bool) {
        return
            keccak256(abi.encodePacked((firstString))) ==
            keccak256(abi.encodePacked((secondString)));
    }
}
