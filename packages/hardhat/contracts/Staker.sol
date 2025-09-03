// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;
    event Stake(address, uint256);
    mapping ( address => uint256 ) public balances;
    uint256 public constant threshold = 32 ether;
    uint256 public deadline = block.timestamp + 45 seconds;
    bool public openForWithdraw;

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Deadline not reached!");
        _;
    }

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
        openForWithdraw = false;
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
    function stake() public payable {
        require(block.timestamp < deadline, "Staking closed.");
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
    function execute() external afterDeadline {
        if (block.timestamp >= deadline) {
            if (address(this).balance >= threshold) {
                exampleExternalContract.complete{value: address(this).balance}();
            }
            else {
                openForWithdraw = true;
            }
        }
    }

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
    function withdraw() public {
        if (openForWithdraw) {
            // appro. code for withdrawal
            openForWithdraw = false;
        }
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return (deadline - block.timestamp);
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}
