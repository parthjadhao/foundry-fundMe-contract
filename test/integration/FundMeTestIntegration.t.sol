// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FundMeDeployScript} from "../../script/FundeMeDeployScript.s.sol";
import {FundFundme, WithdrawFundMe} from "../../script/interaction.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";

contract FundMeTestIntegration is Test {
    FundMe public fundme;
    FundMeDeployScript deployFundme;
    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    address alice = makeAddr("alice");

    function setUp() external {
        deployFundme = new FundMeDeployScript();
        fundme = deployFundme.run();
        vm.deal(alice, STARTING_USER_BALANCE);
    }

    function testUserCanFundAndOwnerCanWithdraw() public {
        uint256 preUserBalance = address(alice).balance;
        uint256 preOwnerBalance = address(fundme.getOwner()).balance;

        // using prank to simulate funding from user address
        vm.prank(alice);
        fundme.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundme));

        uint256 afterUserBalance = address(alice).balance;
        uint256 afterOwnerBalance = address(fundme.getOwner()).balance;

        assertEq(address(fundme).balance, 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}
