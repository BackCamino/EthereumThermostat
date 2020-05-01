pragma solidity ^0.6.1;


/*
Contratto unico.
Inizializzazione dei componenti centralizzata da un amministratore.
Non si attiene alla logica di un modello di coreografia.
*/

contract Thermostat {
    address private admin;
    address private sensor;
    address private heater;
    address private user;

    int16 currentTemp;
    int16 thresholdTemp;

    constructor() public {
        admin = msg.sender;
    }

    function getCurrentTemp() public view returns (int16) {
        return currentTemp;
    }

    function getThresholdTemp() public view returns (int16) {
        return thresholdTemp;
    }

    modifier onlyAddress(address ad) {
        require(msg.sender == ad, "User not allowed");
        _;
    }

    modifier allSubscribed() {
        require(sensor != address(0), "Sensor not initialized");
        require(heater != address(0), "Heater not initialized");
        require(user != address(0), "User not initialized");
        _;
    }

    event HeaterActivation(bool on);

    modifier updateHeater() {
        bool currentStatus = heaterOn();
        _;
        if (heaterOn() != currentStatus) emit HeaterActivation(heaterOn());
    }

    function setSensor(address ad) external onlyAddress(admin) {
        sensor = ad;
    }

    function setHeater(address ad) external onlyAddress(admin) {
        heater = ad;
    }

    function setUser(address ad) external onlyAddress(admin) {
        user = ad;
    }

    function heaterOn() public view allSubscribed returns (bool) {
        return currentTemp < thresholdTemp;
    }

    function setThreshold(int16 temp)
        external
        onlyAddress(user)
        updateHeater
        allSubscribed
    {
        thresholdTemp = temp;
    }

    function setTemp(int16 temp)
        external
        onlyAddress(sensor)
        updateHeater
        allSubscribed
    {
        currentTemp = temp;
    }
}
